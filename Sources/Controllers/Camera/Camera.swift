//
//  Camera.swift
//  HDR Editor
//
//  Created by Anton Heestand on 2021-02-22.
//

import Foundation
import AVKit
import SwiftUI

class Camera: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    private let captureSession: AVCaptureSession = .init()
    
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var backInput: AVCaptureInput?
    private var frontInput: AVCaptureInput?

    private var photoOutput: AVCapturePhotoOutput?
    
    private let exposureValues: [Float] = [-2.0, 0.0, 2.0]
    private var capturedImages: [UIImage]?
    private var competionHandler: ((Result<[UIImage], CameraError>) -> ())?
    
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

    override init() {
        super.init()
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        captureSession.beginConfiguration()
        
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true

        setupInputs()
        setupOutput()
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
    }
    
    
    private func setupInputs() {
        
        if let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = backDevice
            if let backInput = try? AVCaptureDeviceInput(device: backDevice),
                captureSession.canAddInput(backInput) {
                self.backInput = backInput
                captureSession.addInput(backInput)
            }
        }
        
        if let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = frontDevice
            if let frontInput = try? AVCaptureDeviceInput(device: frontDevice),
               captureSession.canAddInput(frontInput) {
                self.frontInput = frontInput
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
        
//        let exposureSettings = [
//            AVCaptureManualExposureBracketedStillImageSettings.manualExposureSettings(exposureDuration: CMTime(value: CMTimeValue(0.01), timescale: CMTimeScale(NSEC_PER_SEC)), iso: 100),
//            AVCaptureManualExposureBracketedStillImageSettings.manualExposureSettings(exposureDuration: CMTime(value: CMTimeValue(0.1), timescale: CMTimeScale(NSEC_PER_SEC)), iso: 100),
//            AVCaptureManualExposureBracketedStillImageSettings.manualExposureSettings(exposureDuration: CMTime(value: CMTimeValue(1.0), timescale: CMTimeScale(NSEC_PER_SEC)), iso: 100),
//        ]
        
        let photoSettings = AVCapturePhotoBracketSettings(rawPixelFormatType: 0,
                                                          processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc],
                                                          bracketedSettings: exposureSettings)
        photoSettings.isLensStabilizationEnabled = photoOutput.isLensStabilizationDuringBracketedCaptureSupported

        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        capturedImages = []
        competionHandler = completion
        
    }
    
    private func captured(error: Error?) {
        guard error == nil else {
            competionHandler?(.failure(.captureFailedWithError(error!)))
            return
        }
        guard let images: [UIImage] = capturedImages else {
            competionHandler?(.failure(.captureFailed("No Images Found")))
            return
        }
        defer { capturedImages = nil }
        guard !images.isEmpty else {
            competionHandler?(.failure(.captureFailed("Image Count is Zero")))
            return
        }
        competionHandler?(.success(images))
    }
    
    // MARK: - Capture Delegate
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("PHOTO willBeginCaptureFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("PHOTO willCapturePhotoFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("PHOTO didCapturePhotoFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("PHOTO didFinishProcessingPhoto", photo.photoCount)
        if let imageData: Data = photo.fileDataRepresentation() {
            if let image: UIImage = UIImage(data: imageData){
                capturedImages?.append(image)
            }
        }
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        captured(error: error)
    }
    
}
