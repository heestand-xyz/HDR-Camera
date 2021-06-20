//
//  HDR.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-22.
//

import UIKit
import RenderKit
import PixelKit

class HDR: ObservableObject {
    
    
    var images: [UIImage] = []
    
    var imagePix0: ImagePIX
    var imagePix1: ImagePIX
    var imagePix2: ImagePIX
    
    var flipFlopPix0: FlipFlopPIX
    var flipFlopPix1: FlipFlopPIX
    var flipFlopPix2: FlipFlopPIX
    
    var monoPix1: ColorShiftPIX
    var monoPix2: ColorShiftPIX
    
    var invertPix1: LevelsPIX
    var invertPix2: LevelsPIX
    
    var levelsPixGamma1: LevelsPIX
    var levelsPixGamma2: LevelsPIX
    
    var blurPix1: BlurPIX
    var blurPix2: BlurPIX
    
    var reorderPix1: ReorderPIX
    var reorderPix2: ReorderPIX
    
    var blendPix1: BlendPIX
    var blendPix2: BlendPIX
    
    var levelsPixBrightness1: LevelsPIX
    var levelsPixBrightness2: LevelsPIX

    var blendsPix: BlendsPIX
    
    var levelsPix: LevelsPIX

    @Published var gamma1: CGFloat = 1.0 {
        didSet { levelsPixGamma1.gamma = gamma1 }
    }
    @Published var gamma2: CGFloat = 1.0 {
        didSet { levelsPixGamma2.gamma = gamma2 }
    }
//    @Published var gamma3: CGFloat = 1.0 {
//        didSet { levelsPixGamma3.gamma = gamma3 }
//    }

    @Published var blur1: CGFloat = 0.25 {
        didSet { blurPix1.radius = blur1 }
    }
    @Published var blur2: CGFloat = 0.25 {
        didSet { blurPix2.radius = blur2 }
    }
//    @Published var blur3: CGFloat = 0.25 {
//        didSet { blurPix3.radius = blur3 }
//    }

    @Published var brightness1: CGFloat = 1.0 {
        didSet { levelsPixBrightness1.brightness = brightness1 }
    }
    @Published var brightness2: CGFloat = 1.0 {
        didSet { levelsPixBrightness2.brightness = brightness2 }
    }
//    @Published var brightness3: CGFloat = 1.0 {
//        didSet { levelsPixBrightness3.brightness = brightness3 }
//    }
    
    let finalPix: PIX
    
    var allPixs: [(String, PIX)] {
        [
            ("imagePix0", imagePix0),
            ("imagePix1", imagePix1),
            ("imagePix2", imagePix2),
            ("flipFlopPix0", flipFlopPix0),
            ("flipFlopPix1", flipFlopPix1),
            ("flipFlopPix2", flipFlopPix2),
            ("monoPix1", monoPix1),
            ("monoPix2", monoPix2),
            ("invertPix1", invertPix1),
            ("invertPix2", invertPix2),
            ("levelsPixGamma1", levelsPixGamma1),
            ("levelsPixGamma2", levelsPixGamma2),
            ("blurPix1", blurPix1),
            ("blurPix2", blurPix2),
            ("reorderPix1", reorderPix1),
            ("reorderPix2", reorderPix2),
            ("blendPix1", blendPix1),
            ("blendPix2", blendPix2),
            ("levelsPixBrightness1", levelsPixBrightness1),
            ("levelsPixBrightness2", levelsPixBrightness2),
            ("blendsPix", blendsPix),
            ("levelsPix", levelsPix),
        ]
    }
    
    enum HDRError: LocalizedError {
        case timeout(Double)
        case badImageCount
        case renderFailed
        var errorDescription: String? {
            switch self {
            case .timeout(let seconds):
                return "HDR Timeout (\(seconds))"
            case .badImageCount:
                return "HDR Bad Image Count"
            case .renderFailed:
                return "HDR Render Failed"
            }
        }
    }
    
    init() {
        
        PixelKit.main.render.bits = ._16

        imagePix0 = ImagePIX()
        imagePix0.name = "imagePix0"
        imagePix1 = ImagePIX()
        imagePix1.name = "imagePix1"
        imagePix2 = ImagePIX()
        imagePix2.name = "imagePix2"

        flipFlopPix0 = FlipFlopPIX()
        flipFlopPix0.name = "flipFlopPix0"
        flipFlopPix0.input = imagePix0
        flipFlopPix1 = FlipFlopPIX()
        flipFlopPix1.name = "flipFlopPix1"
        flipFlopPix1.input = imagePix1
        flipFlopPix2 = FlipFlopPIX()
        flipFlopPix2.name = "flipFlopPix2"
        flipFlopPix2.input = imagePix2
        
        monoPix1 = flipFlopPix1.pixMonochrome()
        monoPix1.name = "monoPix1"
        monoPix2 = flipFlopPix2.pixMonochrome()
        monoPix2.name = "monoPix2"
        
        invertPix1 = monoPix1.pixInvert()
        invertPix1.name = "invertPix1"
        invertPix2 = monoPix2.pixInvert()
        invertPix2.name = "invertPix2"
        
        levelsPixGamma1 = LevelsPIX()
        levelsPixGamma1.name = "levelsPixGamma1"
        levelsPixGamma1.input = invertPix1
        levelsPixGamma2 = LevelsPIX()
        levelsPixGamma2.name = "levelsPixGamma2"
        levelsPixGamma2.input = invertPix2

        blurPix1 = BlurPIX()
        blurPix1.name = "blurPix1"
        blurPix1.input = levelsPixGamma1
        blurPix1.radius = 0.25
        blurPix2 = BlurPIX()
        blurPix2.name = "blurPix2"
        blurPix2.input = levelsPixGamma2
        blurPix2.radius = 0.25
        
        reorderPix1 = ReorderPIX()
        reorderPix1.name = "reorderPix1"
        reorderPix1.inputA = blurPix1
        reorderPix1.inputB = blurPix1
        reorderPix1.alphaChannel = .luma
        reorderPix2 = ReorderPIX()
        reorderPix2.name = "reorderPix2"
        reorderPix2.inputA = blurPix2
        reorderPix2.inputB = blurPix2
        reorderPix2.alphaChannel = .luma
        
        blendPix1 = BlendPIX()
        blendPix1.name = "blendPix1"
        blendPix1.inputA = blurPix1
        blendPix1.inputB = reorderPix1
        blendPix1.blendMode = .multiply
        blendPix2 = BlendPIX()
        blendPix2.name = "blendPix2"
        blendPix2.inputA = blurPix2
        blendPix2.inputB = reorderPix2
        blendPix2.blendMode = .multiply

        levelsPixBrightness1 = LevelsPIX()
        levelsPixBrightness1.name = "levelsPixBrightness1"
        levelsPixBrightness1.input = blendPix1
        levelsPixBrightness2 = LevelsPIX()
        levelsPixBrightness2.name = "levelsPixBrightness2"
        levelsPixBrightness2.input = blendPix2

        blendsPix = BlendsPIX()
        blendsPix.name = "blendsPix"
        blendsPix.blendMode = .add
        blendsPix.inputs = [flipFlopPix0, levelsPixBrightness1, levelsPixBrightness2]
        
        levelsPix = LevelsPIX()
        levelsPix.name = "levelsPix"
        levelsPix.input = blendsPix
        levelsPix.gamma = 0.5
        
        finalPix = levelsPix
        finalPix.name = "finalPix"
        finalPix.view.placement = .fit

    }
    
    func generate(images: [UIImage], completion: @escaping (Result<UIImage, Error>) -> ()) {
        
        print("HDR Camera generate images at \(images.first!.size)")
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            print(">>>>> portraitUpsideDown")
            flipFlopPix0.flop = .right
            flipFlopPix1.flop = .right
            flipFlopPix2.flop = .right
            flipFlopPix0.flip = .x
            flipFlopPix1.flip = .x
            flipFlopPix2.flip = .x
            break
        case .landscapeLeft:
            print(">>>>> landscapeLeft")
            flipFlopPix0.flip = .x
            flipFlopPix1.flip = .x
            flipFlopPix2.flip = .x
            break
        case .landscapeRight:
            print(">>>>> landscapeRight")
            flipFlopPix0.flip = .y
            flipFlopPix1.flip = .y
            flipFlopPix2.flip = .y
        default:
            print(">>>>> default")
            flipFlopPix0.flop = .left
            flipFlopPix1.flop = .left
            flipFlopPix2.flop = .left
            flipFlopPix0.flip = .x
            flipFlopPix1.flip = .x
            flipFlopPix2.flip = .x
        }
        
        load(images: images) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                
                self.timeout(1.0) {
                    if self.finalPix.texture != nil {
                        
                        guard let hdrImage: UIImage = self.finalPix.renderedImage else {
                            self.clear()
                            completion(.failure(HDRError.renderFailed))
                            return true
                        }
                        
                        self.clear()
                        completion(.success(hdrImage))
                        return true
                    }
                    return false
                } timeout: { error in
                    self.clear()
                    completion(.failure(error))
                }
            case .failure(let error):
                self.clear()
                completion(.failure(error))
            }
        }
        
    }
    
    private func load(images: [UIImage], completion: @escaping (Result<Void, Error>) -> ()) {
        
        guard images.count == 3 else {
            completion(.failure(HDRError.badImageCount))
            return
        }
        
        imagePix0.image = images[0]
        imagePix1.image = images[1]
        imagePix2.image = images[2]
        
        timeout(2.5) {
            if self.imagePix0.imageLoaded,
               self.imagePix1.imageLoaded,
               self.imagePix2.imageLoaded {
                completion(.success(()))
                return true
            }
            return false
        } timeout: { error in
            completion(.failure(error))
        }
                
    }
    
    func timeout(_ timeoutSeconds: Double, everySeconds: Double = 0.1, check: @escaping () -> (Bool), timeout: @escaping (Error) -> ()) {
        let startDate = Date()
        Timer.scheduledTimer(withTimeInterval: everySeconds, repeats: true) { timer in
            if check() {
                timer.invalidate()
                return
            }
            if -startDate.timeIntervalSinceNow > timeoutSeconds {
                timer.invalidate()
                timeout(HDRError.timeout(timeoutSeconds))
                return
            }
        }
    }
    
    private func clear() {
        print("HDR Camera - Clear")
        imagePix0.image = nil
        imagePix1.image = nil
        imagePix2.image = nil
        allPixs.forEach { (name, pix) in
            pix.clearRender()
        }
    }
    
}
