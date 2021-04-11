//
//  HDRView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-22.
//

import SwiftUI
import RenderKit

struct HDRView: View {
    
    @ObservedObject var hdr: HDR
    
    var body: some View {
        VStack {

            NODERepView(node: hdr.finalPix)
                .cornerRadius(20)

            HStack(spacing: 30) {
                Text("Gamma")
                    .frame(width: 100, alignment: .trailing)
                Slider(value: $hdr.gamma1, in: 0.0...2.0)
                Slider(value: $hdr.gamma2, in: 0.0...2.0)
            }

            HStack(spacing: 30) {
                Text("Blur")
                    .frame(width: 100, alignment: .trailing)
                Slider(value: $hdr.blur1)
                Slider(value: $hdr.blur2)
            }

            HStack(spacing: 30) {
                Text("Brightness")
                    .frame(width: 100, alignment: .trailing)
                Slider(value: $hdr.brightness1)
                Slider(value: $hdr.brightness2)
            }

        }
    }
    
}

struct HDRView_Previews: PreviewProvider {
    static var previews: some View {
        HDRView(hdr: HDR())
    }
}
