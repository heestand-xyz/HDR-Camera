//
//  HDRCamera.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import MultiViews
import AVKit
import Combine
import CryptoKit
import AsyncGraphics

class HDRCamera: NSObject, ObservableObject {

    static let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

    let alertCenter: AlertCenter = .init()
    
    let hdr: HDR = .init()
    let camera: Camera = .init()
    
    var cameraGraphic: Graphic? {
        liveCameraGraphic ?? frozenCameraGraphic
    }
    @Published var liveCameraGraphic: Graphic?
    @Published var frozenCameraGraphic: Graphic?
    
    @Published var captureAnimation: CGFloat = 0.0
    
    var timeAnimationTimer: Timer?
    @Published var timeAnimation: CGFloat = 0.0

    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    enum State {
        case live
        case capture
        case generating
    }
    @Published var state: State = .live
    
    @Published private(set) var capturedImages: [(id: UUID, image: UIImage)] = []
    @Published var animatedImageIDs: [UUID] = []

    enum CameraControl {
        case none
        case light
        case focus
    }
    @Published var cameraControl: CameraControl = .none
    
    #if !targetEnvironment(macCatalyst)
    @Published var cameraLens: CameraLens = .back(.wide) {
        didSet {
            stopCamera()
            DispatchQueue.main.async {
                self.startCamera(with: self.cameraLens)
            }
            camera.lens = cameraLens
        }
    }
    #endif
    
    @Published var shutter: ShutterOpen = .mid
    
    var cancellables: [AnyCancellable] = []
    
    enum HDRError: LocalizedError {
        case md5CheckFailed(String)
        var errorDescription: String? {
            switch self {
            case .md5CheckFailed(let info):
                return "Checksum Failed: \(info)"
            }
        }
    }
    
    private var cameraTask: Task<Void, Never>?
    
    private var timerReady: Bool = true
    
    // MARK: - Life Cycle -
    
    override init() {
        
        super.init()
        
        startCamera(with: cameraLens)
        
        listenToApp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVolume), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.orientation = UIDevice.current.orientation
            }
            .store(in: &cancellables)
    }
    
    // MARK: - App State
    
    #if os(iOS)
    
    func listenToApp() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    @objc func didBecomeActive() {
        startCamera(with: cameraLens)
    }
    
    @objc func willResignActive() {
        stopCamera()
    }
    
    @objc func willEnterForeground() {}
    
    @objc func didEnterBackground() {
        capturedImages = []
        animatedImageIDs = []
    }
    
    #endif
    
    // MARK: - Camera
    
    func startCamera(with cameraLens: CameraLens) {
        
        cameraTask?.cancel()
        
        cameraTask = Task {
            
            do {
            
                for await graphic in try Graphic.camera(cameraLens == .front ? .front : .back,
                                                        device: cameraLens.deviceType,
                                                        preset: .hd1920x1080) {
                    let cameraGraphic: Graphic = try await {
                        switch cameraLens {
                        case .front:
                            return try await graphic.rotatedLeft()
                        default:
                            return try await graphic.rotatedRight()
                        }
                    }()
                    DispatchQueue.main.async { [weak self] in
                        self?.liveCameraGraphic = cameraGraphic
                        self?.frozenCameraGraphic = nil
                    }
                }
                
            } catch {
                
                DispatchQueue.main.async { [weak self] in
                    self?.alertCenter.alertBug(message: "Camera Failed", error: error)
                }
            }
        }
    }
    
    func stopCamera() {
        cameraTask?.cancel()
        frozenCameraGraphic = liveCameraGraphic
        liveCameraGraphic = nil
    }
    
    func capturePhoto(with interaction: MVInteraction = .endedInside) {
        
        print("HDR Camera capturePhoto")
        
        switch interaction {
        case .started:
            
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.25)) {
                shutter = .max
            }
            
            return
            
        case .endedInside:
            
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.15)) {
                shutter = .min
            }
            RunLoop.current.add(Timer(timeInterval: 0.15, repeats: false, block: { _ in
                withAnimation(.easeInOut(duration: 0.15)) {
                    self.shutter = .mid
                }
            }), forMode: .common)
            
            stopCamera()
            
            capture { result in
                
                switch result {
                case .success(let hdrImage):
                    self.captureDone(hdrImage: hdrImage)
                case .failure(let error):
                    self.captureFailed(error: error)
                }
                
                self.startCamera(with: self.cameraLens)
            }
            
        case .endedOutside:
            
            withAnimation(.easeInOut(duration: 0.25)) {
                shutter = .mid
            }
            
            return
            
        }
    }
    
    func capture(completion: @escaping (Result<UIImage, Error>) -> ()) {
        
        print("HDR Camera capture")
        
        state = .capture
                
        animate(for: 0.5, ease: .easeInOut) { [weak self] fraction in
            self?.timeAnimation += 0.01 * fraction
        } done: { [weak self] in
            guard let self = self else { return }
            guard self.timerReady else { return }
            self.timeAnimationTimer = Timer(timeInterval: 0.01, repeats: true, block: { [weak self] _ in
                self?.timeAnimation += 0.01
            })
            RunLoop.current.add(self.timeAnimationTimer!, forMode: .common)
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            captureAnimation = 1.0
        }
        
        @Sendable func done() {
            
            timerReady = false
            timeAnimationTimer?.invalidate()
            timeAnimationTimer = nil
            animate(for: 0.5, ease: .easeInOut) { [weak self] fraction in
                self?.timeAnimation += 0.01 * (1.0 - fraction)
            }
            withAnimation(.easeInOut(duration: 0.5)) {
                captureAnimation = 0.0
            }
        }
        
        camera.capture { result in
            switch result {
            case .success(let images):
                DispatchQueue.global().async {
                    if !self.check(images: images, id: "originals") {
                        DispatchQueue.main.async {
                            completion(.failure(HDRError.md5CheckFailed("Originals")))
                            done()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.state = .generating
                    }
                    Task {
                        do {
                            let hdrImage: UIImage = try await self.hdr.generate(images: images, cameraLens: self.cameraLens)
                            DispatchQueue.main.async {
                                completion(.success(hdrImage))
                                done()
                            }
                        } catch {
                            DispatchQueue.main.async {
                                #if DEBUG
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    completion(.failure(error))
                                    done()
                                }
                                #else
                                completion(.failure(error))
                                done()
                                #endif
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                    done()
                }
            }
        }
        
    }
    
    var lastMd5s: [String: [String]] = [:]
    
    func check(images: [UIImage], id: String) -> Bool {
        var md5s: [String] = []
        for image in images {
            guard let md5 = md5(image: image) else { break }
            md5s.append(md5)
        }
        guard md5s.count == images.count else {
            self.lastMd5s[id] = []
            return false
        }
        if lastMd5s[id] == md5s {
            return false
        }
        lastMd5s[id] = md5s
        return true
    }
    
    func md5(image: UIImage) -> String? {
        guard let data: Data = image.pngData() else { return nil }
        return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }
    
    func captureDone(hdrImage: UIImage) {
        
        #if !DEBUG
        UIImageWriteToSavedPhotosAlbum(hdrImage, self, #selector(savedImage), nil)
        #endif

        let id: UUID = UUID()
        withAnimation(.easeInOut) {
            capturedImages.append((id: id, image: hdrImage))
        }
        RunLoop.current.add(Timer(timeInterval: 0.1, repeats: false, block: { _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                self.animatedImageIDs.append(id)
            }
        }), forMode: .common)
        
        state = .live
        
    }
    
    func captureFailed(error: Error) {

        state = .live

        if case Camera.CameraError.captureFailedWithError(let error) = error {

            guard error.localizedDescription != "Cannot Record" else {

                alertCenter.alertInfo(title: "HDR Camera", message: "Photo Capture Failed")

                return
            }
        }

        alertCenter.alertBug(error: error)
    }
    
    @objc func savedImage(_ image: UIImage,
                          didFinishSavingWithError error: Error?,
                          contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            alertCenter.alertBug(message: "Save of photo failed.", error: error!)
            return
        }
    }
    
    // MARK: - Capture with Volume Button

    @objc func updateVolume() {
        capturePhoto()
    }
    
}

extension HDRCamera {
    
    enum AnimationEase {
        case linear
        case easeIn
        case easeInOut
        case easeOut
    }
    
    func animate(for duration: CGFloat, ease: AnimationEase = .linear, loop: @escaping (CGFloat) -> (), done: (() -> ())? = nil) {
        let startTime = Date()
        RunLoop.current.add(Timer(timeInterval: 1.0 / Double(UIScreen.main.maximumFramesPerSecond), repeats: true, block: { t in
            let elapsedTime = CGFloat(-startTime.timeIntervalSinceNow)
            let fraction = min(elapsedTime / duration, 1.0)
            var easeFraction = fraction
            switch ease {
            case .linear: break
            case .easeIn: easeFraction = cos(fraction * .pi / 2 - .pi) + 1
            case .easeInOut: easeFraction = cos(fraction * .pi - .pi) / 2 + 0.5
            case .easeOut: easeFraction = cos(fraction * .pi / 2 - .pi / 2)
            }
            loop(easeFraction)
            if fraction == 1.0 {
                done?()
                t.invalidate()
            }
        }), forMode: .common)
    }
    
}
