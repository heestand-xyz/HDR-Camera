//
//  HDR.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-22.
//

import UIKit
import SwiftUI
import AsyncGraphics

class HDREffect: ObservableObject {
    
    enum HDRError: LocalizedError {
        case noImages
        case timeout(Double)
        case badImageCount
        case renderFailed
        var errorDescription: String? {
            switch self {
            case .noImages:
                return "HDR No Images"
            case .timeout(let seconds):
                return "HDR Timeout (\(seconds))"
            case .badImageCount:
                return "HDR Bad Image Count"
            case .renderFailed:
                return "HDR Render Failed"
            }
        }
    }
    
    func generate(images: [UIImage], cameraLens: CameraLens) async throws -> UIImage {
        
        guard !images.isEmpty else {
            throw HDRError.noImages
        }
        
        let firstImage: UIImage = images.first!
        let firstHeight: CGFloat = firstImage.size.height * firstImage.scale
        
        let blurRadius: CGFloat = firstHeight * 0.02
        
        var graphics: [Graphic] = []
        
        for image in images {
            var graphic: Graphic = try await .image(image).highBit()
            graphic = try await graphic.rotatedRight()
            if cameraLens == .front {
                graphic = try await graphic.mirroredHorizontally()
            }
            graphics.append(graphic)
        }
        
        switch await UIDevice.current.orientation {
        case .landscapeLeft:
            for (index, graphic) in graphics.enumerated() {
                graphics[index] = try await graphic.rotatedLeft()
            }
        case .landscapeRight:
            for (index, graphic) in graphics.enumerated() {
                graphics[index] = try await graphic.rotatedRight()
            }
        default:
            break
        }
        
        var maskGraphics: [Graphic] = []
        for (index, graphic) in graphics.enumerated() {
            guard index > 0 else { continue }
            let maskGraphic: Graphic = try await graphic
                .inverted()
                .hue(Angle(degrees: 180))
                .gamma(0.5)
                .blurred(radius: blurRadius)
            maskGraphics.append(maskGraphic)
        }
        
        var maskedGraphics: [Graphic] = []
        for (index, maskGraphic) in maskGraphics.enumerated() {
            let graphic: Graphic = graphics[index + 1]
            let maskedGraphic: Graphic = try await graphic.blended(with: maskGraphic, blendingMode: .multiply)
            maskedGraphics.append(maskedGraphic)
        }
        
        var hdrGraphic: Graphic = graphics.first!
        for maskedGraphic in maskedGraphics {
            hdrGraphic = try await hdrGraphic.blended(with: maskedGraphic, blendingMode: .add)
        }
        hdrGraphic = try await hdrGraphic
            .gamma(0.5)
            .saturated(0.75)
        
        return try await hdrGraphic.image
    }
}
