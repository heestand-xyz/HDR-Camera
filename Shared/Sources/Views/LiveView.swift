//
//  LiveView.swift
//  HDR Editor
//
//  Created by Anton Heestand on 2021-02-22.
//

import SwiftUI
import RenderKit

struct LiveView: View {
    
    @ObservedObject var hdrEditor: HDREditor
    @ObservedObject var camera: Camera
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            NODERepView(node: hdrEditor.finalPix)
                .ignoresSafeArea()
            
            ShutterView(capture: {
                camera.capture()
            })
            .shadow(radius: 10)
            .frame(width: 80, height: 80)
            .padding(.bottom, 50)
            
        }
        
    }
    
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView(hdrEditor: HDREditor(), camera: Camera())
    }
}
