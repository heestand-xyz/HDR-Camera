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
    
    var levelsPixGamma1: LevelsPIX
    var levelsPixGamma2: LevelsPIX
//    var levelsPixGamma3: LevelsPIX

    var blurPix1: BlurPIX
    var blurPix2: BlurPIX
//    var blurPix3: BlurPIX

    var levelsPixBrightness1: LevelsPIX
    var levelsPixBrightness2: LevelsPIX
//    var levelsPixBrightness3: LevelsPIX

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
    
    init() {
        
        PixelKit.main.render.bits = ._16

        imagePix0 = ImagePIX()//.pixScaleResolution(to: 0.25)
        imagePix1 = ImagePIX()//.pixScaleResolution(by: 0.25)
        imagePix2 = ImagePIX()//.pixScaleResolution(by: 0.25)

        levelsPixGamma1 = LevelsPIX()
        levelsPixGamma1.input = imagePix1.pixMonochrome().pixInvert()
        levelsPixGamma2 = LevelsPIX()
        levelsPixGamma2.input = imagePix2.pixMonochrome().pixInvert()
//        levelsPixGamma3 = LevelsPIX()
//        levelsPixGamma3.input = imagePix3.pixMonochrome().pixInvert()

        blurPix1 = BlurPIX()
        blurPix1.input = levelsPixGamma1
        blurPix1.radius = 0.25
        blurPix2 = BlurPIX()
        blurPix2.input = levelsPixGamma2
        blurPix2.radius = 0.25
//        blurPix3 = BlurPIX()
//        blurPix3.input = levelsPixGamma3
//        blurPix3.radius = 0.25

        levelsPixBrightness1 = LevelsPIX()
        levelsPixBrightness1.input = imagePix1.pixMask(pix: blurPix1)
        levelsPixBrightness2 = LevelsPIX()
        levelsPixBrightness2.input = imagePix2.pixMask(pix: blurPix2)
//        levelsPixBrightness3 = LevelsPIX()
//        levelsPixBrightness3.input = imagePix3.pixMask(pix: blurPix3)

        let img = imagePix0
            + levelsPixBrightness1
            + levelsPixBrightness2
//            + levelsPixBrightness3
        let out = img
        finalPix = out.pixGamma(0.5)
        finalPix.view.placement = .fit

    }
    
    func load(images: [UIImage]) {
        guard images.count == 3 else { return }
        imagePix0.image = images[0]
        imagePix1.image = images[1]
        imagePix2.image = images[2]
    }
    
    func clear() {
        imagePix0.image = nil
        imagePix1.image = nil
        imagePix2.image = nil
    }
    
}
