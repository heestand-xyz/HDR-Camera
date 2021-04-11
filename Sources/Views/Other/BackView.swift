//
//  BackView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI
import MultiViews

struct BackView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MVBlurView()
                    .clipShape(RoundedRectangle(cornerRadius: geometry.size.width / 2))
                RoundedRectangle(cornerRadius: geometry.size.width / 2)
                    .stroke(style: StrokeStyle(lineWidth: 2))
            }
        }
    }
}

struct BackView_Previews: PreviewProvider {
    static var previews: some View {
        BackView()
            .frame(width: 40, height: 100)
    }
}
