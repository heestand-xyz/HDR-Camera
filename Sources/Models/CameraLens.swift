//
//  CameraLens.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2022-07-06.
//

import Foundation
import AVKit

#if !targetEnvironment(macCatalyst)
enum CameraLens: Equatable {
    
    enum Back: Equatable {
        case ultraWide
        case wide
        case tele
    }
    
    case back(Back)
    
    case front
    
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
}
#endif
