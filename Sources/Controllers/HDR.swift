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
    
    var levelsPixGamma1: LevelsPIX
    var levelsPixGamma2: LevelsPIX

    var blurPix1: BlurPIX
    var blurPix2: BlurPIX
    
    var levelsPixBrightness1: LevelsPIX
    var levelsPixBrightness2: LevelsPIX

    var blendsPix: BlendsPIX

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
        flipFlopPix0.flop = .right
        flipFlopPix1 = FlipFlopPIX()
        flipFlopPix1.name = "flipFlopPix1"
        flipFlopPix1.input = imagePix1
        flipFlopPix1.flop = .right
        flipFlopPix2 = FlipFlopPIX()
        flipFlopPix2.name = "flipFlopPix2"
        flipFlopPix2.input = imagePix2
        flipFlopPix2.flop = .right
        
        levelsPixGamma1 = LevelsPIX()
        levelsPixGamma1.name = "levelsPixGamma1"
        levelsPixGamma1.input = flipFlopPix1.pixMonochrome().pixInvert()
        levelsPixGamma2 = LevelsPIX()
        levelsPixGamma2.name = "levelsPixGamma2"
        levelsPixGamma2.input = flipFlopPix2.pixMonochrome().pixInvert()

        blurPix1 = BlurPIX()
        blurPix1.name = "blurPix1"
        blurPix1.input = levelsPixGamma1
        blurPix1.radius = 0.25
        blurPix2 = BlurPIX()
        blurPix2.name = "blurPix2"
        blurPix2.input = levelsPixGamma2
        blurPix2.radius = 0.25

        levelsPixBrightness1 = LevelsPIX()
        levelsPixBrightness1.name = "levelsPixBrightness1"
        levelsPixBrightness1.input = flipFlopPix1.pixMask(pix: blurPix1)
        levelsPixBrightness2 = LevelsPIX()
        levelsPixBrightness2.name = "levelsPixBrightness2"
        levelsPixBrightness2.input = flipFlopPix2.pixMask(pix: blurPix2)

        blendsPix = BlendsPIX()
        blendsPix.name = "blendsPix"
        blendsPix.blendMode = .add
        blendsPix.inputs = [flipFlopPix0, levelsPixBrightness1, levelsPixBrightness2]
        
        finalPix = blendsPix.pixGamma(0.5)
        finalPix.name = "finalPix"
        finalPix.view.placement = .fit

    }
    
    func generate(images: [UIImage], completion: @escaping (Result<UIImage, Error>) -> ()) {
        
        print("HDR Camera generate images at \(images.first!.size)")
        
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
        imagePix0.image = nil
        imagePix1.image = nil
        imagePix2.image = nil
    }
    
}
