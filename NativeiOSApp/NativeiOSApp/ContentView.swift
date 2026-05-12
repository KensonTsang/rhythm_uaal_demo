//
//  ContentView.swift
//  NativeiOSApp
//
//  Created by Kenson Tsang on 11/05/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var launched = false

    var body: some View {
        VStack(spacing: 16) {
            Text("UaaL Host")
                .font(.title)

            Button(launched ? "Show Unity" : "Launch Unity") {
                if launched {
                    UnityLauncher.shared().showUnity()
                } else {
                    print("Launching Unity from SwiftUI...")
                    UnityLauncher.shared().launchUnityIfNeeded()
                    print("Unity launch call finished")
                    launched = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
