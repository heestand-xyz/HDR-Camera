//
//  PhotosView.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-14.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

import SwiftUI

struct PhotosView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var main: MainViewModel
    
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
            
            TabView(selection: $pageIndex) {
                ForEach(main.capturedImages, id: \.id) { pack in
                    PhotoView(image: pack.image)
                        .tag(main.capturedImages.map(\.id).firstIndex(of: pack.id) ?? 0)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
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
            pageIndex = main.capturedImages.count - 1
        }
        .sheet(isPresented: $showShareSheet, content: {
            if pageIndex >= 0 && pageIndex < main.capturedImages.count {
                ShareView(image: main.capturedImages[pageIndex].image)
            }
        })
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView(main: MainViewModel())
    }
}
