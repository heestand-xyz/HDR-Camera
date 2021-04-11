//
//  CameraLightControlView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

#if !targetEnvironment(macCatalyst)

import SwiftUI

struct CameraLightControlView: View {

    @ObservedObject var hdrCamera: HDRCamera

    var body: some View {
        VStack {
            VStack {
                VSlider(value: $hdrCamera.lightISO, active: $hdrCamera.manualLight)
                    .frame(width: 40, height: 100)
                    .shadow(radius: 10)
                Text("ISO")
                    .shadow(radius: 5)
                VSlider(value: $hdrCamera.lightExposure, active: $hdrCamera.manualLight)
                    .frame(width: 40, height: 100)
                    .shadow(radius: 10)
                Text("LIGHT")
                    .shadow(radius: 5)
                Toggle(isOn: Binding<Bool>(get: {
                    !hdrCamera.manualLight
                }, set: { active in
                    hdrCamera.manualLight = !active
                }), label: { EmptyView() })
                    .toggleStyle(SwitchToggleStyle(tint: Color(white: 0.9)))
                    .frame(width: 50).offset(x: -5)
                    .shadow(radius: 10)
                Text("AUTO")
                    .shadow(radius: 5)
                Button(action: {
                    withAnimation {
                        hdrCamera.cameraControl = .none
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .black))
                        .padding(5)
                })
                .shadow(radius: 5)
            }
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .accentColor(.white)
        }
    }
}

struct CameraLightControlView_Previews: PreviewProvider {
    static var previews: some View {
        CameraLightControlView(hdrCamera: HDRCamera())
    }
}

#endif
