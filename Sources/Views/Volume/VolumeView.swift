//
//  VolumeView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct VolumeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        MPVolumeView()
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}
