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

class HDRCamera: NSObject, ObservableObject {

    static let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

    let alertCenter: AlertCenter = .init()
    
    let hdr: HDR = .init()
    let camera: Camera = .init()
    
    let cameraPix: CameraPIX
    let levelsPix: LevelsPIX
    let finalPix: PIX
    
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
    
    static let thumbnailSize = CGSize(width: 200 / (16 / 9), height: 200)
    
    var cancellables: [AnyCancellable] = []

    // MARK: - Life Cycle -
    
    override init() {
        
        cameraPix = CameraPIX()
        cameraPix.view.placement = .fill
        
        levelsPix = LevelsPIX()
        levelsPix.input = cameraPix
        levelsPix.gamma = 0.5
        
        finalPix = levelsPix
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
        camera.capture { result in
            switch result {
            case .success(let images):
                self.state = .generating
                self.hdr.generate(images: images) { result in
                    switch result {
                    case .success(let hdrImage):
                        completion(.success(hdrImage))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    self.cameraPix.active = true
                }
            case .failure(let error):
                completion(.failure(error))
                self.cameraPix.active = true
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
