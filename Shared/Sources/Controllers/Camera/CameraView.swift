//
//  CameraView.swift
//  HDR Editor
//
//  Created by Anton Heestand on 2021-02-22.
//

import SwiftUI
import AVKit

struct CameraView: UIViewRepresentable {
    
    let captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let previewView = UIView()
        previewView.layer.addSublayer(context.coordinator.previewLayer)
//        context.coordinator.previewLayer.connection?.videoOrientation = .portrait
        return previewView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("uiView.bounds:", uiView.bounds)
        context.coordinator.previewLayer.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(captureSession: captureSession)
    }
    
    class Coordinator {
        let previewLayer: AVCaptureVideoPreviewLayer
        init(captureSession: AVCaptureSession) {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
    }
    
}

