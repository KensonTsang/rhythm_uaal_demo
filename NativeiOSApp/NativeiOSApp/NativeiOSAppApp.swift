//
//  NativeiOSAppApp.swift
//  NativeiOSApp
//
//  Created by Kenson Tsang on 11/05/2026.
//

import SwiftUI

@main
struct NativeiOSAppApp: App {
    
    init() {
        _ = UnityLauncher.shared()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if let windowScene = UIApplication.shared.connectedScenes
                        .first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        NativeWindowHolder.shared.window = window
                    }
                }
        }
    }
}
