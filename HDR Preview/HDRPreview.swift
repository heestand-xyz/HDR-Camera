//
//  HDRPreview.swift
//  HDRPreview
//
//  Created by Anton Heestand on 2021-08-07.
//

import Foundation
import UIKit

class HDRPreview: ObservableObject {
    
    let hdr: HDR = .init()
    
    @Published var hdrImage: UIImage?
    
    init() {
        
        let images: [UIImage] = [
            UIImage(named: "cannon1")!,
            UIImage(named: "cannon2")!,
            UIImage(named: "cannon3")!,
        ]
        
        hdr.generate(images: images) { result in
            switch result {
            case .success(let hdrImage):
                self.hdrImage = hdrImage
            case .failure(let error):
                print("HDR Error:", error)
            }
        }
    }
    
}
