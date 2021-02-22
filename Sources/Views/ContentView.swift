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
    
    @StateObject var hdrCamera: HDRCamera = HDRCamera()
    
    var body: some View {
        ZStack {
            
            if hdrCamera.state == .live {
                NODERepView(node: hdrCamera.finalPix)
                    .ignoresSafeArea()
            }
            
            if hdrCamera.state != .edit {
                VStack {
                    Spacer()
                    ShutterView(capture: {
                        hdrCamera.capture()
                    })
                    .shadow(radius: 10)
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 50)
                }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
