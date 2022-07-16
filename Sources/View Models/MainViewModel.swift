//
//  MainViewModel.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import MultiViews
import AVKit
import Combine
import CryptoKit
import AsyncGraphics

class MainViewModel: NSObject, ObservableObject {

    // MARK: State
    
    enum State {
        case live
        case capture
        case generating
    }
    
    @Published var state: State = .live
    
    // MARK: Version
    
    static let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

    // MARK: Alert Center
    
    let alertCenter: AlertCenter = .init()
    
    // MARK: Camera
    
    private let camera: Camera = .init()

    // MARK: HDR Effect
    
    private let hdrEffect: HDREffect = .init()
    
    // MARK: Graphics
    
    var cameraGraphic: Graphic? {
        liveCameraGraphic ?? frozenCameraGraphic
    }
    @Published var liveCameraGraphic: Graphic?
    @Published var frozenCameraGraphic: Graphic?
    
    // MARK: Capture
    
    @Published var captureAnimation: CGFloat = 0.0
    
    // MARK: Time
    
    private var timeAnimationTimer: Timer?
    @Published var timeAnimation: CGFloat = 0.0

    private var timerReady: Bool = true
    
    // MARK: Orientation
    
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    // MARK: Captured Images
    
    @Published private(set) var capturedImages: [(id: UUID, image: UIImage)] = []
    @Published var animatedImageIDs: [UUID] = []

    // MARK: Camera Lens
    
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
    
    // MARK: Shutter
    
    @Published var shutter: ShutterOpen = .mid
    
    // MARK: Cancellables
    
    var cancellables: [AnyCancellable] = []
    
    // MARK: Error
    
    enum HDRError: LocalizedError {
        case md5CheckFailed(String)
        var errorDescription: String? {
            switch self {
            case .md5CheckFailed(let info):
                return "Checksum Failed: \(info)"
            }
        }
    }
    
    // MARK: Tasks
    
    private var cameraTask: Task<Void, Never>?
    
    // MARK: App
    
    @Published var appActive: Bool = true
    
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
        appActive = true
    }
    
    @objc func willResignActive() {
        appActive = false
    }
    
    @objc func willEnterForeground() {
        startCamera(with: cameraLens)
    }
    
    @objc func didEnterBackground() {
        capturedImages = []
        animatedImageIDs = []
        stopCamera()
        frozenCameraGraphic = nil
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
    
    // MARK: - Capture
    
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
        
        camera.capture { [weak self] result in
            
            guard let self = self else { return }
            
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
                            let hdrImage: UIImage = try await self.hdrEffect.generate(images: images, cameraLens: self.cameraLens)
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
    
    func captureDone(hdrImage: UIImage) {
        
        UIImageWriteToSavedPhotosAlbum(hdrImage, self, #selector(savedImage), nil)
        
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
    
    @objc func savedImage(_ image: UIImage,
                          didFinishSavingWithError error: Error?,
                          contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            alertCenter.alertBug(message: "Save of photo failed.", error: error!)
            return
        }
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
    
    // MARK: - Check
    
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
    
    // MARK: - Capture with Volume Button

    @objc func updateVolume() {
        capturePhoto()
    }
}
