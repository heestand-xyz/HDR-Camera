//
//  HDRCamera.swift
//  HDR Editor
//
//  Created by Anton Heestand on 2021-02-15.
//

import Foundation
import CoreGraphics
import MultiViews
import RenderKit
import PixelKit

class LegacyHDRCamera: ObservableObject {
    
    let hdr: HDR = .init()
    let camera: Camera = .init()
    
    enum State {
        case live
        case capture
        case edit
    }
    @Published var state: State = .live
    
    @Published var images: [MPImage] = []

    let cameraPix: CameraPIX
    let finalPix: PIX

    init() {

        cameraPix = CameraPIX()
        finalPix = cameraPix.pixGamma(0.5)
        
    }
    
    func capture() {
        state = .capture
        cameraPix.active = false
        camera.capture { result in
            switch result {
            case .success(let images):
                print("CAPTURE", images.count)
                self.hdr.load(images: images)
                self.images = images
                self.state = .edit
            case .failure(let error):
                print("FAILED", error)
                self.state = .live
            }
            self.cameraPix.active = true
        }
    }
    
    func live() {
        state = .live
        images = []
        hdr.clear()
    }
    
}
