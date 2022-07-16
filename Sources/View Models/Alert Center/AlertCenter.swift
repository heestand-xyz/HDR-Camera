//
//  AlertCenter.swift
//  HDR Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

import Foundation
import SwiftUI

class AlertCenter: ObservableObject {
    
    enum Alert {
        
        case info(String?, String)
        case action(String?, String, String, () -> ())
        case bug(String?, String?, Error)
        
        var defaultTitle: String {
            switch self {
            case .info, .action:
                return "HDR Camera"
            case .bug:
                return "HDR Camera Bug"
            }
        }
        
        var title: String {
            switch self {
            case .info(let title, _):
                return title ?? defaultTitle
            case .action(let title, _, _, _):
                return title ?? defaultTitle
            case .bug(let title, _, _):
                return title ?? defaultTitle
            }
        }
        
        var message: String {
            var message: String = ""
            switch self {
            case .info(_, let msg):
                message += msg
            case .action(_, let msg, _, _):
                message += msg
            case .bug(_, let msg, let error):
                if let msg = msg {
                    message += msg + "\n"
                }
                message += error.localizedDescription
            }
            return message// + "\n" + footer
        }
        
        var footer: String { "v\(MainViewModel.version)" }
    }
        
    @Published var alert: Alert?
    
    func alertInfo(title: String? = nil, message: String) {
        withAnimation(.linear(duration: 0.25)) {
            alert = .info(title, message)
        }
    }
    
    func alertBug(title: String? = nil, message: String? = nil, error: Error) {
        withAnimation(.linear(duration: 0.25)) {
            alert = .bug(title, message, error)
        }
    }
}
