//
//  NativeWindowHolder.swift
//  NativeiOSApp
//
//  Created by Kenson Tsang on 14/05/2026.
//

import Foundation


class NativeWindowHolder {
    static let shared = NativeWindowHolder()
    weak var window: UIWindow?
}
