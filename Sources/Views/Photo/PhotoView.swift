//
//  PhotoView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

import SwiftUI

struct PhotoView: View {
    
    let image: UIImage
    
    var body: some View {
       
        ZStack {
        
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke()
                        .opacity(0.1)
                )
                .padding()
        }
    }
}
