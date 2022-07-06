//
//  CameraLens.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2022-07-06.
//

import Foundation
import AVKit

#if !targetEnvironment(macCatalyst)
enum CameraLens: Equatable, Hashable, CaseIterable {
    
    enum Back: Equatable {
        case wide
        case ultraWide
        case tele
    }
    
    case back(Back)
    
    case front
    
    
    var description: String {
        switch self {
        case .front:
            return "1x"
        case .back(.tele):
            return "3x"
        case .back(.wide):
            return "1x"
        case .back(.ultraWide):
            return "0.5x"
        }
    }
    
    static var hasUltrawide: Bool {
        AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back) != nil
    }
    static var hasTele: Bool {
        AVCaptureDevice.default(.builtInTelephotoCamera, for: AVMediaType.video, position: .back) != nil
    }
    var deviceType: AVCaptureDevice.DeviceType {
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
    }
    
    static var allCases: [CameraLens] {
        [
            .front,
            .back(.wide),
            .back(.ultraWide),
            .back(.tele),
        ]
    }
    
    static let supported: [CameraLens: Bool] = {
        var supported: [CameraLens: Bool] = [:]
        for camera in CameraLens.allCases {
            supported[camera] = camera.getSupported()
        }
        return supported
    }()
    
    var isSupported: Bool {
        Self.supported[self] ?? false
    }
    
    private func getSupported() -> Bool {
        let session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(deviceType, for: .video, position: self == .front ? .front : .back) else { return false }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return false }
        return session.canAddInput(input)
    }
}
#endif
