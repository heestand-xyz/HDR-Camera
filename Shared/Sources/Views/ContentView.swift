//
//  ContentView.swift
//  Shared
//
//  Created by Anton Heestand on 2021-02-15.
//

import SwiftUI
import RenderKit
import PixelKit

struct ContentView: View {
    
    @StateObject var hdrEditor: HDREditor = HDREditor()
    
    var body: some View {
        ZStack {
            
            LiveView(hdrEditor: hdrEditor, camera: hdrEditor.camera)
            
//            NODERepView(node: hdrEditor.finalPix)
//                .cornerRadius(20)
//
//            HStack(spacing: 30) {
//                Text("Gamma")
//                    .frame(width: 100, alignment: .trailing)
//                Slider(value: $hdrEditor.gamma1, in: 0.0...2.0)
//                Slider(value: $hdrEditor.gamma2, in: 0.0...2.0)
//                Slider(value: $hdrEditor.gamma3, in: 0.0...2.0)
//            }
//
//            HStack(spacing: 30) {
//                Text("Blur")
//                    .frame(width: 100, alignment: .trailing)
//                Slider(value: $hdrEditor.blur1)
//                Slider(value: $hdrEditor.blur2)
//                Slider(value: $hdrEditor.blur3)
//            }
//
//            HStack(spacing: 30) {
//                Text("Brightness")
//                    .frame(width: 100, alignment: .trailing)
//                Slider(value: $hdrEditor.brightness1)
//                Slider(value: $hdrEditor.brightness2)
//                Slider(value: $hdrEditor.brightness3)
//            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
