//
//  AlertView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2022-07-06.
//

import SwiftUI

struct AlertView: View {
    
    let alert: AlertCenter.Alert
    
    let close: () -> ()
    
    var body: some View {
        ZStack {
            
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Text(alert.title)
                    .font(.title2)
                    .padding(.horizontal, 35)
                Text(alert.message)
                Text(alert.footer)
                    .font(.footnote)
                    .opacity(0.5)
            }
            .foregroundColor(.black)
            .padding()
            .overlay(ZStack(alignment: .topTrailing) {
                Color.clear
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 25))
                }
                .foregroundColor(.black)
                .padding(10)
            })
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white).opacity(0.9))
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(alert: .info("Title", "Message"), close: {})
    }
}
