//
//  VolumeView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct VolumeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        MPVolumeView()
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
    
}
