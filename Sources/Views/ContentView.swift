//
//  ContentView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

import SwiftUI
import AsyncGraphics

struct ContentView: View {
    
    @ObservedObject var main: MainViewModel
    @ObservedObject var alertCenter: AlertCenter
    
    @State var showPhoto: Bool = false

    var body: some View {
        ZStack {
            
            ZStack {
                
                // Camera
                if let graphic = main.cameraGraphic {
                    
                    ZStack {
                    
                        GeometryReader { _ in
                        
                            GraphicView(graphic: graphic)
                                .scaledToFill()
                                .ignoresSafeArea()
                                .blur(radius: main.appActive && main.state == .live ? 0 : 15)
                                .brightness(main.state == .capture ? 0.15 : 0)
                        }
                        
                        if main.state == .capture {
                            
                            VStack(spacing: 5) {
                                Text("Capturing Photo")
                                Text("Hold Camera Still")
                                    .font(.footnote)
                            }
                            .opacity(0.5)
                            
                        } else if main.state == .generating {
                        
                            VStack(spacing: 5) {
                                Text("Editing Photo")
                                Text("in High Dynamic Range")
                                    .font(.footnote)
                            }
                            .opacity(0.5)
                        }
                    }
                    .animation(.linear, value: main.state)
                    .animation(.linear, value: main.appActive)
                }
                
                // Volume
                VolumeView()
                    .opacity(0.001)
                
                // Capture
                CaptureView(main: main, showPhoto: {
                    showPhoto = true
                })
                .shadow(radius: 10)
                
                // Controls & Shutter
                VStack {
                    
                    Spacer()
                    
                    ZStack {
                        
                        ControlsView(main: main)
                        
                        ShutterView(capture: { interaction in
                            main.capturePhoto(with: interaction)
                        }, shutter: $main.shutter)
                        .rotationEffect(Angle(degrees: -90 * Double(main.timeAnimation)))
                        .frame(width: 80, height: 80)
                        .shadow(radius: 10)
                    }
                    .frame(height: 80)
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
                PhotosView(main: main)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(main: MainViewModel(), alertCenter: AlertCenter())
    }
}
