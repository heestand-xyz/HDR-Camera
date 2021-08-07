//
//  ContentView.swift
//  HDR Preview
//
//  Created by Anton Heestand on 2021-08-07.
//

import SwiftUI
import RenderKit

struct ContentView: View {
    
    @StateObject var hdrPreview = HDRPreview()
    
    var body: some View {
        ZStack {
            Checker()
                .ignoresSafeArea()
            VStack {
                
                HStack {
                    Group {
                        Image("cannon1")
                            .resizable()
                        Image("cannon2")
                            .resizable()
                        Image("cannon3")
                            .resizable()
                    }
                    .aspectRatio(contentMode: .fit)
                }
                .frame(height: 100)
                
                if let image: UIImage = hdrPreview.hdrImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                }
                
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
