//
//  HDR_EditorApp.swift
//  Shared
//
//  Created by Anton Heestand on 2021-02-15.
//

import SwiftUI

@main
struct HDRCameraApp: App {
    
    @StateObject var main = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(main: main,
                        alertCenter: main.alertCenter)
        }
    }
}
