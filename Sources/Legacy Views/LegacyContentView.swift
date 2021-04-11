//
//  ContentView.swift
//  Shared
//
//  Created by Anton Heestand on 2021-02-15.
//

import SwiftUI
import RenderKit
import PixelKit

struct LegacyContentView: View {
    
    @StateObject var hdrCamera: LegacyHDRCamera = LegacyHDRCamera()
    
    var body: some View {
        ZStack {
            
            if hdrCamera.state == .live {
                NODERepView(node: hdrCamera.finalPix)
                    .ignoresSafeArea()
            }
            
            if hdrCamera.state != .edit {
                Button(action: {
                    hdrCamera.capture()
                }, label: {
                    Text("Capture")
                })
            }
            
            if hdrCamera.state == .edit {
                VStack {
                    Button {
                        hdrCamera.live()
                    } label: {
                        Text("Live")
                    }
                    HDRView(hdr: hdrCamera.hdr)
                    HStack {
                        ForEach(0..<hdrCamera.images.count, id: \.self) { index in
                            Image(uiImage: hdrCamera.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
            }
            
        }
    }
}

struct LegacyContentView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyContentView()
    }
}
