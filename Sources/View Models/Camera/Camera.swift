//
//  Camera.swift
//  HDR Editor
//
//  Created by Anton Heestand on 2021-02-22.
//

import Foundation
import AVKit
import Combine
import SwiftUI

class Camera: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    let captureSession: AVCaptureSession = .init()
    
    private var camera: AVCaptureDevice?
    private var input: AVCaptureInput?

    private var photoOutput: AVCapturePhotoOutput?
    
    private let exposureValues: [Float] = [-2.0, -0.5, 0.5, 2.0]
    private var capturedImages: [UIImage]?
    private var completionHandler: ((Result<[UIImage], CameraError>) -> ())?
    
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    var lens: CameraLens = .back(.wide) {
        didSet {
            setupInputs()
        }
    }
    
    enum CameraError: LocalizedError {
        case captureFailed(String)
        case captureFailedWithError(Error)
        var errorDescription: String? {
            switch self {
            case .captureFailed(let info):
                return "Camera Capture Failed: \(info)"
            case .captureFailedWithError(let error):
                return "Camera Capture Failed with Error: \(error.localizedDescription)"
            }
        }
    }
    
    var cancellables: [AnyCancellable] = []

    override init() {
        
        super.init()
        
        setup()
        
        NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.orientation = UIDevice.current.orientation
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        captureSession.beginConfiguration()
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true

        setupInputs()
        setupOutput()
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    private func setupInputs() {
        
        if let input = input {
            captureSession.removeInput(input)
        }
        
        camera = nil
        input = nil
        
        if let camera: AVCaptureDevice = AVCaptureDevice.default(lens.deviceType,
                                                                 for: .video,
                                                                 position: lens == .front ? .front : .back) {
            self.camera = camera
            if let input = try? AVCaptureDeviceInput(device: camera),
               captureSession.canAddInput(input) {
                self.input = input
                captureSession.addInput(input)
            }
        }
        
    }
    
    private func setupOutput() {
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput!) {
            captureSession.addOutput(photoOutput!)
        }
    }
    
    // MARK: - Capture
    
    func capture(completion: @escaping (Result<[UIImage], CameraError>) -> ()) {
        
        guard let photoOutput: AVCapturePhotoOutput = photoOutput else { return }
                
        let makeAutoExposureSettings = AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(exposureTargetBias:)
        let exposureSettings = exposureValues.map(makeAutoExposureSettings)
        
        let photoSettings = AVCapturePhotoBracketSettings(rawPixelFormatType: 0,
                                                          processedFormat: [AVVideoCodecKey : AVVideoCodecType.jpeg],
                                                          bracketedSettings: exposureSettings)
        photoSettings.isLensStabilizationEnabled = photoOutput.isLensStabilizationDuringBracketedCaptureSupported

        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        capturedImages = []
        completionHandler = completion
    }
    
    private func captured(error: Error?) {
        guard error == nil else {
            print("HDR Camera - Captured Error:", error!)
            completionHandler?(.failure(.captureFailedWithError(error!)))
            return
        }
        guard let images: [UIImage] = capturedImages else {
            completionHandler?(.failure(.captureFailed("No Images Found")))
            return
        }
        print("HDR Camera - Captured Images at \(images.map(\.size))")
        defer { capturedImages = nil }
        guard !images.isEmpty else {
            completionHandler?(.failure(.captureFailed("Image Count is Zero")))
            return
        }
        DispatchQueue.main.async {
            self.completionHandler?(.success(images))
        }
    }
    
    // MARK: - Capture Delegate
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("HDR Camera - Will Begin Capture For")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("HDR Camera - Will Capture Photo For")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("HDR Camera - Did Capture Photo For")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("HDR Camera - Did Finish Processing Photo", photo.photoCount)
        if let imageData: Data = photo.fileDataRepresentation() {
            if let image: UIImage = UIImage(data: imageData){
                capturedImages?.append(image)
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("HDR Camera - Did Finish Capture For")
        captured(error: error)
    }
}
