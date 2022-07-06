//
//  ControlsView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2022-07-06.
//

import SwiftUI

struct ControlsView: View {
    
    @ObservedObject var hdrCamera: HDRCamera

    var body: some View {
        
        HStack {
            
            /// Camera
            ZStack {
                
                if hdrCamera.cameraLens != .front {
                    
                    if CameraLens.back(.tele).isSupported || CameraLens.back(.ultraWide).isSupported {
                        
                        Button {
                            let supportedBackCameras: [CameraLens] = CameraLens.allCases
                                .filter { camera in
                                    guard camera != .front else { return false }
                                    guard camera.isSupported else { return false }
                                    return true
                                }
                            guard !supportedBackCameras.isEmpty else { return }
                            guard let currentIndex = supportedBackCameras.firstIndex(of: hdrCamera.cameraLens) else { return }
                            let nextIndex = (currentIndex + 1) % supportedBackCameras.count
                            hdrCamera.cameraLens = supportedBackCameras[nextIndex]
                        } label: {
                            EmptyView()
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 3)
                                Text(hdrCamera.cameraLens.description)
                                    .font(.system(size: hdrCamera.cameraLens == .back(.ultraWide) ? 12 : 15, weight: .bold, design: .monospaced))
                            }
                            .frame(width: 40, height: 40)
                        }
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    }
                }
            }
            .frame(width: 40)
            
            Spacer()
                .frame(width: 150)
            
            /// Flip Camera
            Button {
                if hdrCamera.cameraLens == .front {
                    hdrCamera.cameraLens = .back(.wide)
                } else {
                    hdrCamera.cameraLens = .front
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 30))
            }
            .foregroundColor(.white)
            .shadow(radius: 5)
        }
        .disabled(hdrCamera.state != .live)
        .opacity(hdrCamera.state == .live ? 1.0 : 0.0)
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(hdrCamera: HDRCamera())
    }
}