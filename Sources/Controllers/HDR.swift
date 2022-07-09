//
//  HDR.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-22.
//

import UIKit
import AsyncGraphics

class HDR: ObservableObject {
    
//    var imagePix0: ImagePIX
//    var imagePix1: ImagePIX
//    var imagePix2: ImagePIX
//
//    var flipFlopPix0: FlipFlopPIX
//    var flipFlopPix1: FlipFlopPIX
//    var flipFlopPix2: FlipFlopPIX
//
//    var monoPix1: ColorShiftPIX
//    var monoPix2: ColorShiftPIX
//
//    var invertPix1: LevelsPIX
//    var invertPix2: LevelsPIX
//
//    var levelsPixGamma1: LevelsPIX
//    var levelsPixGamma2: LevelsPIX
//
//    var blurPix1: BlurPIX
//    var blurPix2: BlurPIX
//
//    var reorderPix1: ReorderPIX
//    var reorderPix2: ReorderPIX
//
//    var blendPix1: BlendPIX
//    var blendPix2: BlendPIX
//
//    var levelsPixBrightness0: LevelsPIX
//    var levelsPixBrightness1: LevelsPIX
//    var levelsPixBrightness2: LevelsPIX
//
//    var blendsPix: BlendsPIX
//
//    var levelsPix: LevelsPIX

//    @Published var gamma1: CGFloat = 1.0 {
//        didSet { levelsPixGamma1.gamma = gamma1 }
//    }
//    @Published var gamma2: CGFloat = 1.0 {
//        didSet { levelsPixGamma2.gamma = gamma2 }
//    }
//
//    @Published var blur1: CGFloat = 0.25 {
//        didSet { blurPix1.radius = blur1 }
//    }
//    @Published var blur2: CGFloat = 0.25 {
//        didSet { blurPix2.radius = blur2 }
//    }
//
//    @Published var brightness1: CGFloat = 1.0 {
//        didSet { levelsPixBrightness1.brightness = brightness1 }
//    }
//    @Published var brightness2: CGFloat = 1.0 {
//        didSet { levelsPixBrightness2.brightness = brightness2 }
//    }
//    let finalPix: PIX
    
//    var allPixs: [(String, PIX)] {
//        [
//            ("imagePix0", imagePix0),
//            ("imagePix1", imagePix1),
//            ("imagePix2", imagePix2),
//            ("flipFlopPix0", flipFlopPix0),
//            ("flipFlopPix1", flipFlopPix1),
//            ("flipFlopPix2", flipFlopPix2),
//            ("monoPix1", monoPix1),
//            ("monoPix2", monoPix2),
//            ("invertPix1", invertPix1),
//            ("invertPix2", invertPix2),
//            ("levelsPixGamma1", levelsPixGamma1),
//            ("levelsPixGamma2", levelsPixGamma2),
//            ("blurPix1", blurPix1),
//            ("blurPix2", blurPix2),
//            ("reorderPix1", reorderPix1),
//            ("reorderPix2", reorderPix2),
//            ("blendPix1", blendPix1),
//            ("blendPix2", blendPix2),
//            ("levelsPixBrightness1", levelsPixBrightness1),
//            ("levelsPixBrightness2", levelsPixBrightness2),
//            ("blendsPix", blendsPix),
//            ("levelsPix", levelsPix),
//        ]
//    }
    
    init() {
        
//        PixelKit.main.render.bits = ._16

//        imagePix0 = ImagePIX()
//        imagePix0.name = "imagePix0"
//        imagePix1 = ImagePIX()
//        imagePix1.name = "imagePix1"
//        imagePix2 = ImagePIX()
//        imagePix2.name = "imagePix2"
//
//        flipFlopPix0 = FlipFlopPIX()
//        flipFlopPix0.name = "flipFlopPix0"
//        flipFlopPix0.input = imagePix0
//        flipFlopPix1 = FlipFlopPIX()
//        flipFlopPix1.name = "flipFlopPix1"
//        flipFlopPix1.input = imagePix1
//        flipFlopPix2 = FlipFlopPIX()
//        flipFlopPix2.name = "flipFlopPix2"
//        flipFlopPix2.input = imagePix2
//
//        monoPix1 = flipFlopPix1.pixMonochrome()
//        monoPix1.name = "monoPix1"
//        monoPix2 = flipFlopPix2.pixMonochrome()
//        monoPix2.name = "monoPix2"
//
//        invertPix1 = monoPix1.pixInvert()
//        invertPix1.name = "invertPix1"
//        invertPix2 = monoPix2.pixInvert()
//        invertPix2.name = "invertPix2"
//
//        levelsPixGamma1 = LevelsPIX()
//        levelsPixGamma1.name = "levelsPixGamma1"
//        levelsPixGamma1.input = invertPix1
//        levelsPixGamma2 = LevelsPIX()
//        levelsPixGamma2.name = "levelsPixGamma2"
//        levelsPixGamma2.input = invertPix2
//
//        blurPix1 = BlurPIX()
//        blurPix1.name = "blurPix1"
//        blurPix1.input = levelsPixGamma1
//        blurPix1.radius = 0.25
//        blurPix2 = BlurPIX()
//        blurPix2.name = "blurPix2"
//        blurPix2.input = levelsPixGamma2
//        blurPix2.radius = 0.25
//
//        reorderPix1 = ReorderPIX()
//        reorderPix1.name = "reorderPix1"
//        reorderPix1.inputA = blurPix1
//        reorderPix1.inputB = blurPix1
//        reorderPix1.alphaChannel = .luma
//        reorderPix2 = ReorderPIX()
//        reorderPix2.name = "reorderPix2"
//        reorderPix2.inputA = blurPix2
//        reorderPix2.inputB = blurPix2
//        reorderPix2.alphaChannel = .luma
//
//        blendPix1 = BlendPIX()
//        blendPix1.name = "blendPix1"
//        blendPix1.inputA = flipFlopPix1
//        blendPix1.inputB = reorderPix1
//        blendPix1.blendMode = .multiply
//        blendPix2 = BlendPIX()
//        blendPix2.name = "blendPix2"
//        blendPix2.inputA = flipFlopPix2
//        blendPix2.inputB = reorderPix2
//        blendPix2.blendMode = .multiply
//
//        levelsPixBrightness0 = LevelsPIX()
//        levelsPixBrightness0.name = "levelsPixBrightness0"
//        levelsPixBrightness0.input = flipFlopPix0
//        levelsPixBrightness0.brightness = 1.25
//        levelsPixBrightness1 = LevelsPIX()
//        levelsPixBrightness1.name = "levelsPixBrightness1"
//        levelsPixBrightness1.input = blendPix1
//        levelsPixBrightness1.brightness = 2.25
//        levelsPixBrightness2 = LevelsPIX()
//        levelsPixBrightness2.name = "levelsPixBrightness2"
//        levelsPixBrightness2.input = blendPix2
//        levelsPixBrightness2.brightness = 2.25
//
//        blendsPix = BlendsPIX()
//        blendsPix.name = "blendsPix"
//        blendsPix.blendMode = .add
//        blendsPix.inputs = [levelsPixBrightness0, levelsPixBrightness1, levelsPixBrightness2]
//
//        levelsPix = LevelsPIX()
//        levelsPix.name = "levelsPix"
//        levelsPix.input = blendsPix
//        levelsPix.gamma = 0.8
//
//        finalPix = levelsPix
//        finalPix.name = "finalPix"
//        finalPix.view.placement = .fit

    }
    
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
        
        let blurRadius: CGFloat = firstHeight * 0.01
        
        var graphics: [Graphic] = []
        
        for image in images {
            var graphic: Graphic = try await .image(image).highBit()
            graphic = try await graphic.rotatedRight()
            if cameraLens == .front {
                graphic = try await graphic.mirroredHorizontally()
            }
            graphics.append(graphic)
        }
        
        var maskGraphics: [Graphic] = []
        for (index, graphic) in graphics.enumerated() {
            guard index > 0 else { continue }
            let maskGraphic: Graphic = try await graphic.inverted().blurred(radius: blurRadius).gamma(0.5)
            maskGraphics.append(maskGraphic)
        }
        
        var maskedGraphics: [Graphic] = []
        for (index, maskGraphic) in maskGraphics.enumerated() {
            let graphic: Graphic = graphics[index + 1]
            let maskedGraphic: Graphic = try await graphic.blended(with: maskGraphic, blendingMode: .multiply)
            maskedGraphics.append(maskedGraphic)
        }
        
        var hdrGraphic: Graphic = graphics.first!
        for maskedGraphic in maskGraphics {
            hdrGraphic = try await hdrGraphic.blended(with: maskedGraphic, blendingMode: .add)
        }
        hdrGraphic = try await hdrGraphic.gamma(0.7)
        
        return try await hdrGraphic.image
    }
}
