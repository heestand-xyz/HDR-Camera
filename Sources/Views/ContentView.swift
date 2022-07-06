//
//  ContentView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI
import AsyncGraphics

struct ContentView: View {
    
    @ObservedObject var hdrCamera: HDRCamera
    @ObservedObject var alertCenter: AlertCenter
    
    @State var showPhoto: Bool = false

    var body: some View {
        ZStack {
            
            ZStack {
                
                // Camera
                if let graphic = hdrCamera.cameraGraphic {
                    GraphicView(graphic: graphic)
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                
                // Volume
                VolumeView()
                    .opacity(0.001)
                
                // Capture
                CaptureView(hdrCamera: hdrCamera, showPhoto: {
                    showPhoto = true
                })
                .shadow(radius: 10)
                
                // Shutter
                VStack {
                    Spacer()
                    ShutterView(capture: { interaction in
                        hdrCamera.capturePhoto(with: interaction)
                    }, shutter: $hdrCamera.shutter)
                    .rotationEffect(Angle(degrees: -90 * Double(hdrCamera.timeAnimation)))
                    .frame(width: 80, height: 80)
                    .shadow(radius: 10)
                    .padding(.bottom, 50)
                }
            }
            .blur(radius: alertCenter.alert != nil ? 10 : 0)
            
            if let alert = alertCenter.alert {
                AlertView(alert: alert) {
                    withAnimation(.linear(duration: 0.25)) {
                        alertCenter.alert = nil
                    }
                }
            }
        }
        .sheet(isPresented: Binding<Bool>(get: {
            showPhoto
        }, set: { active in
            if !active {
                showPhoto = false
            }
        })) {
            if showPhoto {
                PhotosView(hdrCamera: hdrCamera)
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(hdrCamera: HDRCamera(), alertCenter: AlertCenter())
    }
}
