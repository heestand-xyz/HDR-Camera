//
//  HDREditor.swift
//  HDR Editor
//
//  Created by Anton Heestand on 2021-02-15.
//

import Foundation
import CoreGraphics
import MultiViews
import Carpaccio
import RenderKit
import PixelKit

class HDREditor: ObservableObject {
    
    let camera: Camera = .init()
    
    
//    var images: [MPImage] = []
//
//    var levelsPixGamma1: LevelsPIX
//    var levelsPixGamma2: LevelsPIX
//    var levelsPixGamma3: LevelsPIX
//
//    var blurPix1: BlurPIX
//    var blurPix2: BlurPIX
//    var blurPix3: BlurPIX
//
//    var levelsPixBrightness1: LevelsPIX
//    var levelsPixBrightness2: LevelsPIX
//    var levelsPixBrightness3: LevelsPIX
//
//    @Published var gamma1: CGFloat = 1.0 {
//        didSet { levelsPixGamma1.gamma = gamma1 }
//    }
//    @Published var gamma2: CGFloat = 1.0 {
//        didSet { levelsPixGamma2.gamma = gamma2 }
//    }
//    @Published var gamma3: CGFloat = 1.0 {
//        didSet { levelsPixGamma3.gamma = gamma3 }
//    }
//
//    @Published var blur1: CGFloat = 0.25 {
//        didSet { blurPix1.radius = blur1 }
//    }
//    @Published var blur2: CGFloat = 0.25 {
//        didSet { blurPix2.radius = blur2 }
//    }
//    @Published var blur3: CGFloat = 0.25 {
//        didSet { blurPix3.radius = blur3 }
//    }
//
//    @Published var brightness1: CGFloat = 1.0 {
//        didSet { levelsPixBrightness1.brightness = brightness1 }
//    }
//    @Published var brightness2: CGFloat = 1.0 {
//        didSet { levelsPixBrightness2.brightness = brightness2 }
//    }
//    @Published var brightness3: CGFloat = 1.0 {
//        didSet { levelsPixBrightness3.brightness = brightness3 }
//    }
    
    let cameraPix: CameraPIX

    let finalPix: PIX
    
    init() {

        
        cameraPix = CameraPIX()

        finalPix = cameraPix
        
        
//        let names: [String] = [
//            "DSC_0045",
//            "DSC_0044",
//            "DSC_0043",
//            "DSC_0042",
//        ]
//
//        let urls = names.map({ name in Bundle.main.url(forResource: name, withExtension: "NEF")! })
//        let loaders = urls.map({ url in ImageLoader(imageURL: url, thumbnailScheme: .decodeFullImage) })
//        let results = loaders.map({ loader in try! loader.loadCGImage(colorSpace: nil, cancelled: nil) })
//        images = results.map({ result in Texture.image(from: result.0) })
//
//        PixelKit.main.render.bits = ._16
//
//        let img0 = ImagePIX(image: images[0]).pixScaleResolution(by: 0.25)
//        let img1 = ImagePIX(image: images[1]).pixScaleResolution(by: 0.25)
//        let img2 = ImagePIX(image: images[2]).pixScaleResolution(by: 0.25)
//        let img3 = ImagePIX(image: images[3]).pixScaleResolution(by: 0.25)
//
//        levelsPixGamma1 = LevelsPIX()
//        levelsPixGamma1.input = img1.pixMonochrome().pixInvert()
//        levelsPixGamma2 = LevelsPIX()
//        levelsPixGamma2.input = img2.pixMonochrome().pixInvert()
//        levelsPixGamma3 = LevelsPIX()
//        levelsPixGamma3.input = img3.pixMonochrome().pixInvert()
//
//        blurPix1 = BlurPIX()
//        blurPix1.input = levelsPixGamma1
//        blurPix1.radius = 0.25
//        blurPix2 = BlurPIX()
//        blurPix2.input = levelsPixGamma2
//        blurPix2.radius = 0.25
//        blurPix3 = BlurPIX()
//        blurPix3.input = levelsPixGamma3
//        blurPix3.radius = 0.25
//
//        levelsPixBrightness1 = LevelsPIX()
//        levelsPixBrightness1.input = img1.pixMask(pix: blurPix1)
//        levelsPixBrightness2 = LevelsPIX()
//        levelsPixBrightness2.input = img2.pixMask(pix: blurPix2)
//        levelsPixBrightness3 = LevelsPIX()
//        levelsPixBrightness3.input = img3.pixMask(pix: blurPix3)
//
//        let img = img0
//            + levelsPixBrightness1
//            + levelsPixBrightness2
//            + levelsPixBrightness3
//        let out = img
//        finalPix = out.pixGamma(0.5)
//        finalPix.view.placement = .fit


    }
    
}
