//
//  AlertCenter.swift
//  Layer Camera
//
//  Created by Anton Heestand on 2021-02-13.
//  Copyright © 2021 Hexagons. All rights reserved.
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
            return message + "\n" + footer
        }
        var button: (String, () -> ())? {
            switch self {
            case .action(_, _, let button, let action):
                return (button, action)
            default:
                return nil
            }
        }
        
        var footer: String { "v\(HDRCamera.version)" }
        
        var alert: SwiftUI.Alert {
            if let button = button {
                return SwiftUI.Alert(title: Text(title), message: Text(message),
                                     primaryButton: SwiftUI.Alert.Button.cancel(Text("Cancel")),
                                     secondaryButton: SwiftUI.Alert.Button.default(Text(button.0), action: button.1))
            } else {
                return SwiftUI.Alert(title: Text(title), message: Text(message),
                                     dismissButton: SwiftUI.Alert.Button.cancel(Text("Ok")))
            }
        }
        
    }
    @Published var alert: Alert?
    
    func alertInfo(title: String? = nil, message: String) {
        alert = .info(title, message)
    }
    
    func alertAction(title: String? = nil, message: String, button: String, action: @escaping () -> ()) {
        alert = .action(title, message, button, action)
    }
    
    func alertBug(title: String? = nil, message: String? = nil, error: Error) {
        alert = .bug(title, message, error)
    }
    
}
