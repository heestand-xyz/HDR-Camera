//
//  ControlsView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2022-07-06.
//

import SwiftUI

struct ControlsView: View {
    
    @ObservedObject var main: MainViewModel

    var body: some View {
        
        HStack {
            
            /// Camera
            ZStack {
                
                if main.cameraLens != .front {
                    
                    if CameraLens.back(.tele).isSupported || CameraLens.back(.ultraWide).isSupported {
                        
                        Button {
                           
                            let supportedBackCameras: [CameraLens] = CameraLens.allCases
                                .filter { camera in
                                    guard camera != .front else { return false }
                                    guard camera.isSupported else { return false }
                                    return true
                                }
                            
                            guard !supportedBackCameras.isEmpty else { return }
                            
                            guard let currentIndex = supportedBackCameras.firstIndex(of: main.cameraLens) else { return }
                            let nextIndex = (currentIndex + 1) % supportedBackCameras.count
                            
                            main.cameraLens = supportedBackCameras[nextIndex]
                            
                        } label: {
                            
                            ZStack {
                            
                                Circle()
                                    .stroke(lineWidth: 3)
                                
                                Text(main.cameraLens.description)
                                    .font(.system(size: main.cameraLens == .back(.ultraWide) ? 12 : 15, weight: .bold, design: .monospaced))
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
                if main.cameraLens == .front {
                    main.cameraLens = .back(.wide)
                } else {
                    main.cameraLens = .front
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 30))
            }
            .foregroundColor(.white)
            .shadow(radius: 5)
        }
        .disabled(main.state != .live)
        .opacity(main.state == .live ? 1.0 : 0.0)
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(main: MainViewModel())
    }
}
