//
//  CameraControlsView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

#if !targetEnvironment(macCatalyst)

import SwiftUI
import MultiViews

struct CameraControlsView: View {
    
    @ObservedObject var hdrCamera: HDRCamera
    
    var hasMultiCameras: Bool {
        HDRCamera.Camera.hasTele || HDRCamera.Camera.hasUltrawide
    }
    
    var body: some View {
        ZStack {
            BackView()
            VStack(spacing: 10) {
                
                Button(action: {
                    if hdrCamera.camera == .front {
                        hdrCamera.camera = .back(.wide)
                    } else {
                        hdrCamera.camera = .front
                    }
                }, label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                })
                .font(.system(size: 26))
                
                if hasMultiCameras {
                    
                    Button(action: {
                        if case .back(let back) = hdrCamera.camera {
                            switch back {
                            case .ultraWide:
                                if HDRCamera.Camera.hasTele {
                                    hdrCamera.camera = .back(.tele)
                                } else {
                                    hdrCamera.camera = .back(.wide)
                                }
                            case .wide:
                                if HDRCamera.Camera.hasUltrawide {
                                    hdrCamera.camera = .back(.ultraWide)
                                } else {
                                    hdrCamera.camera = .back(.tele)
                                }
                            case .tele:
                                hdrCamera.camera = .back(.wide)
                            }
                        }
                    }, label: {
                        Text(String(format: "x%.1f", hdrCamera.camera.xFactor))
                            .fontWeight(.bold)
                            .font(.system(size: 17))
                    })
                    .disabled(hdrCamera.camera == .front)
                
                }
                
                Button(action: {
                    withAnimation {
                        hdrCamera.cameraControl = .focus
                    }
                }, label: {
                    Image(systemName: hdrCamera.manualFocus ? "smallcircle.fill.circle.fill" : "smallcircle.fill.circle")
                })
                .font(.system(size: 30))
                
                Button(action: {
                    withAnimation {
                        hdrCamera.cameraControl = .light
                    }
                }, label: {
                    Image(systemName: hdrCamera.manualLight ? "sun.max.fill" : "sun.max")
                })
                .font(.system(size: 30))
                
            }
            .accentColor(.white)
        }
        .frame(width: 50, height: hasMultiCameras ? 175 : 145)
        .shadow(radius: 10)
    }
    
}

struct CameraControlsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraControlsView(hdrCamera: HDRCamera())
    }
}

#endif
