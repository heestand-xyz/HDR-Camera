//
//  ShareView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import Foundation
import SwiftUI

struct ShareView: UIViewControllerRepresentable {
    
    var image: UIImage
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
}
