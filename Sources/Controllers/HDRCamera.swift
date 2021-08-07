//
//  HDRCamera.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import Foundation
import UIKit
import RenderKit
import PixelKit
import SwiftUI
import MultiViews
import AVKit
import Combine
import CryptoKit

class HDRCamera: NSObject, ObservableObject {

    static let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

    let alertCenter: AlertCenter = .init()
    
    let hdr: HDR = .init()
    let camera: Camera = .init()
    
    let cameraPix: CameraPIX
    let levelsPix: LevelsPIX
    let blurPix: BlurPIX
    let finalPix: PIX
    
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
    @Published var manualLight: Bool = false {
        didSet {
            cameraPix.manualExposure = manualLight
        }
    }
    @Published var lightExposure: CGFloat = 0.5 {
        didSet {
            cameraPix.exposure = lightExposure
        }
    }
    @Published var lightISO: CGFloat = 0.5 {
        didSet {
            cameraPix.iso = lightISO
        }
    }
    @Published var manualFocus: Bool = false {
        didSet {
            cameraPix.manualFocus = manualFocus
        }
    }
    @Published var focus: CGFloat = 0.5 {
        didSet {
            cameraPix.focus = focus
        }
    }
    #endif
    
    #if !targetEnvironment(macCatalyst)
    enum CameraLens: Equatable {
        enum Back: Equatable {
            case ultraWide
            case wide
            case tele
        }
        case back(Back)
        case front
        var value: CameraPIX.Camera {
            switch self {
            case .back(let back):
                switch back {
                case .ultraWide:
                    return .ultraWide
                case .wide:
                    return .back
                case .tele:
                    return .tele
                }
            case .front:
                return .front
            }
        }
        var xFactor: CGFloat {
            switch self {
            case .back(let back):
                switch back {
                case .ultraWide:
                    return 0.5
                case .wide:
                    return 1.0
                case .tele:
                    return 2.0
                }
            case .front:
                return 1.0
            }
        }
        static var hasUltrawide: Bool {
            AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back) != nil
        }
        static var hasTele: Bool {
            AVCaptureDevice.default(.builtInTelephotoCamera, for: AVMediaType.video, position: .back) != nil
        }
        var device: AVCaptureDevice? {
            AVCaptureDevice.default({
                switch self {
                case .back(let backLens):
                    switch backLens {
                    case .ultraWide:
                        return .builtInUltraWideCamera
                    case .wide:
                        return .builtInWideAngleCamera
                    case .tele:
                        return .builtInTelephotoCamera
                    }
                case .front:
                    return .builtInWideAngleCamera
                }
            }(), for: .video, position: self == .front ? .front : .back)
        }
    }
    @Published var cameraLens: CameraLens = .back(.wide) {
        didSet {
            cameraPix.camera = cameraLens.value
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

    // MARK: - Life Cycle -
    
    override init() {
        
        cameraPix = CameraPIX()
        cameraPix.view.placement = .fill
        
        levelsPix = LevelsPIX()
        levelsPix.input = cameraPix
        levelsPix.gamma = 0.5
        
        blurPix = BlurPIX()
        blurPix.input = levelsPix
        blurPix.radius = 0.0
        
        finalPix = blurPix
        finalPix.view.placement = .fill
        finalPix.view.checker = false
        
        super.init()
        
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
        
    }
    
    @objc func willResignActive() {
        
    }
    
    @objc func willEnterForeground() {
        
    }
    
    @objc func didEnterBackground() {
        capturedImages = []
        animatedImageIDs = []
    }
    
    #endif
    
    // MARK: - Camera
    
    func capturePhoto(with interaction: MVInteraction = .endedInside) {
        
        print("HDRCamera capturePhoto")
        
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
            
        case .endedOutside:
            
            withAnimation(.easeInOut(duration: 0.25)) {
                shutter = .mid
            }
            
            return
            
        }
        
//        guard let image: UIImage = finalPix.renderedImage else {
//            alertCenter.alertInfo(message: "Photo could not be captured.")
//            return
//        }
        
        capture { result in
            switch result {
            case .success(let hdrImage):
                self.captureDone(hdrImage: hdrImage)
            case .failure(let error):
                self.captureFailed(error: error)
            }
        }

    }
    
    func capture(completion: @escaping (Result<UIImage, Error>) -> ()) {
        
        print("HDRCamera capture")
        
        state = .capture
        
        cameraPix.active = false
        
        animate(for: 0.5, ease: .easeInOut) { [weak self] fraction in
            self?.blurPix.radius = 0.1 * fraction
            self?.timeAnimation += 0.01 * fraction
        } done: { [weak self] in
            guard let self = self else { return }
            self.timeAnimationTimer = Timer(timeInterval: 0.01, repeats: true, block: { [weak self] _ in
                self?.timeAnimation += 0.01
            })
            RunLoop.current.add(self.timeAnimationTimer!, forMode: .common)
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            captureAnimation = 1.0
        }
        
        func done() {
            
            self.cameraPix.active = true
            
            timeAnimationTimer?.invalidate()
            timeAnimationTimer = nil
            animate(for: 0.5, ease: .easeInOut) { [weak self] fraction in
                self?.blurPix.radius = 0.1 - 0.1 * fraction
                self?.timeAnimation += 0.01 * (1.0 - fraction)
            }
            withAnimation(.easeInOut(duration: 0.5)) {
                captureAnimation = 0.0
            }
            
        }
        
        camera.capture { result in
            switch result {
            case .success(let images):
                if !self.check(images: images, id: "originals") {
                    completion(.failure(HDRError.md5CheckFailed("Originals")))
                    return
                }
                self.state = .generating
                self.hdr.generate(images: images) { result in
                    defer { done() }
                    switch result {
                    case .success(let hdrImage):
                        if !self.check(images: [hdrImage], id: "hdr") {
                            completion(.failure(HDRError.md5CheckFailed("HDR")))
                            return
                        }
                        completion(.success(hdrImage))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
                done()
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
        
        UIImageWriteToSavedPhotosAlbum(hdrImage, self, #selector(savedImage), nil)

        let id: UUID = UUID()
        print(">>>>>>>>>>>>>>>>>>>>>>>>> ID", id)
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
//        fatalError("Capture Failed: \(error.localizedDescription)")
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
