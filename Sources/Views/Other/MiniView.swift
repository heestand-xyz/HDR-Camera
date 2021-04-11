//
//  MiniView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI
import RenderKit
import PixelKit

struct MiniView: View {
    
    let pix: PIX
    
    var body: some View {
        
        NODERepView(node: pix)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(lineWidth: 2))
        
    }
    
}

struct MiniView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            MiniView(pix: NoisePIX())
        }
    }
}
