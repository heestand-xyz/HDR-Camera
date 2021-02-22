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

    let captureSession: AVCaptureSession = .init()
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var backInput: AVCaptureInput?
    var frontInput: AVCaptureInput?

    var photoOutput: AVCapturePhotoOutput?

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
    
    func capture() {
        
        guard let photoOutput: AVCapturePhotoOutput = photoOutput else { return }
        
        let captureSettigns = AVCapturePhotoSettings()
        
        let exposureValues: [Float] = [-2, 0, +2]
        let makeAutoExposureSettings = AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(exposureTargetBias:)
        let exposureSettings = exposureValues.map(makeAutoExposureSettings)
        
        let photoSettings = AVCapturePhotoBracketSettings(rawPixelFormatType: 0,
                                                          processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc],
                                                          bracketedSettings: exposureSettings)
        photoSettings.isLensStabilizationEnabled = photoOutput.isLensStabilizationDuringBracketedCaptureSupported

        photoOutput.capturePhoto(with: captureSettigns, delegate: self)
        
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
        print("PHOTO didFinishProcessingPhoto", photo.photoCount, photo.sequenceCount)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("PHOTO didFinishCaptureFor")
    }
    
}
