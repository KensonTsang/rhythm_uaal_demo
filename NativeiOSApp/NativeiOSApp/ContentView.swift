//
//  ContentView.swift
//  NativeiOSApp
//
//  Created by Kenson Tsang on 11/05/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var launched = false
    @State private var showingDummyUnity = false
    @State private var unityMessage = "Text message from unity"

    var body: some View {
        VStack(spacing: 16) {
            Text("UaaL Host")
                .font(.title)
                .onAppear{
                    NotificationCenter.default.addObserver(
                            forName: NSNotification.Name("ShowNativeUINotification"),
                            object: nil,
                            queue: .main
                        ) { _ in
                            NativeWindowHolder.shared.window?.makeKeyAndVisible()
                        }

                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("KillUnityNotification"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        launched = false
                    }

                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("ChangeUnityTextMessageNotification"),
                        object: nil,
                        queue: .main
                    ) { notification in
                        if let msg = notification.userInfo?["message"] as? String {
                            unityMessage = "Receive message: \(msg)"
                            
                            NativeOverlayWindow.shared.showNativeAlert(
                                message: unityMessage
                            )
                        }
                    }
                }

            if !unityMessage.isEmpty {
                Text(unityMessage)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }

            Button(launched || showingDummyUnity ? "Show Unity" : "Launch Unity") {
                #if targetEnvironment(simulator)
                showingDummyUnity = true
                #else
                print("showUnity")
                UnityLauncher.shared().showUnity()
                launched = true
                #endif
                NativeOverlayWindow.shared.showOverlay()
            }
            .buttonStyle(.borderedProminent)
                        
        }
        .padding()
        .fullScreenCover(isPresented: $showingDummyUnity) {
            DummyUnityView(isPresented: $showingDummyUnity)
        }
    }
}

struct DummyUnityView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("UnityInGame")
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
        .overlay(alignment: .topTrailing) {
            Button("Close") {
                isPresented = false
            }
            .padding()
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    ContentView()
}
