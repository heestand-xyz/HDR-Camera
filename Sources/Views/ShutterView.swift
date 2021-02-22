//
//  ShutterView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI
import PolyKit
import MultiViews

enum ShutterOpen: CGFloat {
    case min = 0.0
    case mid = 0.5
    case max = 1.0
}

struct ShutterView: View {
    
    let capture: () -> ()

    @State var shutter: ShutterOpen = .mid
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<6) { index in
                    Poly(count: 3, relativeCornerRadius: 0.25)
                        .scaleEffect(0.75)
                        .rotationEffect(Angle(degrees: (Double(index) / 6.0) * 360 - 90))
                        .offset(x: cos((CGFloat(index) / 6.0) * .pi * 2) * geo.size.height * 0.425,
                                y: sin((CGFloat(index) / 6.0) * .pi * 2) * geo.size.height * 0.425)
                        .offset(x: cos((CGFloat(index) / 6.0) * .pi * 2 + .pi * 0.5) * geo.size.height * shutter.rawValue * 0.35,
                                y: sin((CGFloat(index) / 6.0) * .pi * 2 + .pi * 0.5) * geo.size.height * shutter.rawValue * 0.35)
                }
                MVInteractView { interaction in
                    
                    switch interaction {
                    case .started:
                        
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            shutter = .max
                        }
                        
                        return
                        
                    case .endedInside:
                        
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.15)) {
                            shutter = .min
                        }
                        RunLoop.current.add(Timer(timeInterval: 0.15, repeats: false, block: { _ in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                self.shutter = .mid
                            }
                        }), forMode: .common)

                        capture()

                    case .endedOutside:
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            shutter = .mid
                        }
                        
                        return
                        
                    }
                    
                }
            }
            .clipShape(Circle())
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
    
}

struct ShutterView_Previews: PreviewProvider {
    static var previews: some View {
        ShutterView(capture: {})
            .padding(128)
            .frame(width: 1024, height: 1024)
            .previewLayout(.sizeThatFits)
    }
}
