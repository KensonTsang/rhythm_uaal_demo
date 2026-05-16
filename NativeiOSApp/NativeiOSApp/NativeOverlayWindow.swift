//
//  NativeOverlayWindow.swift
//  NativeiOSApp
//
//  Created by Kenson Tsang on 15/05/2026.
//

import UIKit
import SwiftUI

private class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }
}

class NativeOverlayWindow: UIWindow {
    static let shared = NativeOverlayWindow()

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }

    private init() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first as? UIWindowScene else {
            fatalError("No window scene available")
        }
        super.init(windowScene: windowScene)

        self.windowLevel = .alert + 1
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showOverlay() {
        let hostingVC = UIHostingController(rootView: UnityOverlayView())
        hostingVC.view.backgroundColor = .clear
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false

        let containerVC = UIViewController()
        containerVC.view = PassthroughView()
        containerVC.view.backgroundColor = .clear

        containerVC.addChild(hostingVC)
        containerVC.view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: containerVC)

        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: containerVC.view.safeAreaLayoutGuide.topAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: containerVC.view.trailingAnchor, constant: -20),
        ])

        self.rootViewController = containerVC
        self.isHidden = false
        self.makeKeyAndVisible()
    }

    func hideOverlay() {
        self.isHidden = true
    }
}
