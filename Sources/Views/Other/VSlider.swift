//
//  VSlider.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI
import MultiViews

struct VSlider: View {
    
    @Binding var value: CGFloat
    @Binding var active: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                BackView()
                RoundedRectangle(cornerRadius: geometry.size.width / 2)
                    .frame(height: geometry.size.width + value * (geometry.size.height - geometry.size.width))
                    .opacity(active ? 1.0 : 0.5)
            }
            .gesture(DragGesture().onChanged({ value in
                if !active {
                    active = true
                }
                let fraction: CGFloat = (value.location.y - (geometry.size.width / 2)) / (geometry.size.height - geometry.size.width)
                self.value = min(max(1.0 - fraction, 0.0), 1.0)
            }))
        }
    }
    
}

struct VSlider_Previews: PreviewProvider {
    static var previews: some View {
        VSlider(value: .constant(0.5), active: .constant(true))
            .frame(width: 50, height: 200)
    }
}
