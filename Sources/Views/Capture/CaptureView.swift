//
//  CaptureView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI

struct CaptureView: View {
    
    @ObservedObject var hdrCamera: HDRCamera
    
    let showPhoto: () -> ()
    
    @Namespace private var heroNamespace

    var body: some View {
    
        ZStack(alignment: .bottomLeading) {
            
            Color.clear
            
            ForEach(hdrCamera.capturedImages.filter({ !hdrCamera.animatedImageIDs.contains($0.id) }), id: \.id) { pack in
                GeometryReader { geo in
                    Image(uiImage: pack.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .matchedGeometryEffect(id: pack.id, in: heroNamespace)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
                .ignoresSafeArea()
            }
            
            Button(action: {
                showPhoto()
            }, label: {
                ZStack {
                    ForEach(hdrCamera.capturedImages.filter({ hdrCamera.animatedImageIDs.contains($0.id) }), id: \.id) { pack in
                        Image(uiImage: pack.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .aspectRatio(1.0, contentMode: .fit)
                            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous).aspectRatio(1.0, contentMode: .fit))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(style: StrokeStyle(lineWidth: 2)).aspectRatio(1.0, contentMode: .fit))
                            .matchedGeometryEffect(id: pack.id, in: heroNamespace)
                            .frame(width: 50, height: 50)
                            .rotationEffect(Angle(degrees: -10 * Double(index(id: pack.id))))
                            .offset(x: -2.5 * CGFloat(index(id: pack.id)),
                                    y: -7.5 * CGFloat(index(id: pack.id)))
                            .opacity(3.0 - Double(index(id: pack.id)))
                    }
                }
                .compositingGroup()
            })
            .accentColor(.white)
            .frame(width: 50, height: 50)
            .padding(.leading, 20)
            .padding(.bottom, 65)
            
        }

    }
    
    func index(id: UUID) -> Int {
        hdrCamera.capturedImages.count - (hdrCamera.capturedImages.firstIndex(where: { $0.id == id }) ?? 0) - 1
    }
    
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(hdrCamera: HDRCamera(), showPhoto: {})
    }
}
