//
//  UnityOverlayView.swift
//  NativeiOSApp
//
//  Created by Kenson Tsang on 15/05/2026.
//

import SwiftUI

struct UnityOverlayView: View {
    var body: some View {
        Button ("swiftUI - Close"){
            NativeOverlayWindow.shared.hideOverlay()
            UnityLauncher.shared().hideUnityAndShowNative()
        }
        .padding(.top, 10)
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    UnityOverlayView()
}
