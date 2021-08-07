//
//  PhotosView.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2021 Hexagons. All rights reserved.
//

import SwiftUI

struct PhotosView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var hdrCamera: HDRCamera
    
    @State var showShareSheet: Bool = false
    
    @State var pageIndex: Int = 0
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Done")
                })
                .padding()
            }
            
            Spacer()
            
//            PagesView(pageIndex: $pageIndex) {
//                hdrCamera.capturedImages.map { pack in
//                    (id: pack.id,
//                     view: PhotoView(image: pack.image)
//                        #if DEBUG
//                        .overlay(Text(pack.id.uuidString).padding().background(Color.black))
//                        #endif
//                     )
//                }
//            }
            
            TabView(selection: $pageIndex) {
                ForEach(hdrCamera.capturedImages, id: \.id) { pack in
                    PhotoView(image: pack.image)
                        .tag(hdrCamera.capturedImages.map(\.id).firstIndex(of: pack.id) ?? 0)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
//            HStack {
//                ForEach(hdrCamera.capturedImages, id: \.id) { pack in
//                    Circle()
//                        .frame(width: 7.5, height: 7.5)
//                        .opacity(pageIndex == hdrCamera.capturedImages.firstIndex(where: { $0.id == pack.id }) ? 1.0 : 0.25)
//                }
//            }
//            .opacity(hdrCamera.capturedImages.count > 1 ? 1.0 : 0.0)
            
            HStack {
                
                Spacer()
                
                Button(action: {
                    showShareSheet = true
                }, label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                })
                
                Spacer()
            
                Button(action: {
                    UIApplication.shared.open(URL(string:"photos-redirect://")!)
                }, label: {
                    Label("Photos", systemImage: "photo.on.rectangle.angled")
                })
                
                Spacer()
            
            }
            .padding()
            
            Spacer()
            
        }
        .onAppear {
            pageIndex = hdrCamera.capturedImages.count - 1
        }
        .sheet(isPresented: $showShareSheet, content: {
            if pageIndex >= 0 && pageIndex < hdrCamera.capturedImages.count {
                ShareView(image: hdrCamera.capturedImages[pageIndex].image)
            }
        })
        
    }
    
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView(hdrCamera: HDRCamera())
    }
}
