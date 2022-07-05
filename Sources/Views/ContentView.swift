//
//  ContentView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var hdrCamera: HDRCamera
    @ObservedObject var alertCenter: AlertCenter
    
    @State var showPhoto: Bool = false

    var body: some View {
        ZStack {
            
            // Camera
//            NODERepView(node: hdrCamera.finalPix)
//                .ignoresSafeArea()
            
            // Volume
            VolumeView()
                .opacity(0.001)
            
            // Capture
            CaptureView(hdrCamera: hdrCamera, showPhoto: {
                showPhoto = true
            })
            .shadow(radius: 10)
            
//            #if !targetEnvironment(macCatalyst)
//            // Controls
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Color.clear
//                    CameraControlsView(hdrCamera: hdrCamera)
//                        .offset(x: hdrCamera.cameraControl == .none ? 0 : -geo.size.width - 10)
//                    CameraLightControlView(hdrCamera: hdrCamera)
//                        .offset(x: hdrCamera.cameraControl == .light ? 0 : -geo.size.width - 10)
//                    CameraFocusControlView(hdrCamera: hdrCamera)
//                        .offset(x: hdrCamera.cameraControl == .focus ? 0 : -geo.size.width - 10)
//                }
//                .padding()
//            }
//            #endif
            
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
        .alert(isPresented: Binding<Bool>(get: {
            alertCenter.alert != nil
        }, set: { show in
            if !show {
                alertCenter.alert = nil
            }
        }), content: { alertCenter.alert!.alert })
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
