//
//  swifty_proteinsApp.swift
//  swifty-proteins
//
//  Created by Stina on 05/09/2022.
//

import SwiftUI

@main
struct swifty_proteinsApp: App {
    @State private var isUnlocked: Bool = false
    @State private var noBiometrics: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView(isUnlocked: $isUnlocked, noBiometrics: $noBiometrics)
                .onChange(of: scenePhase) { (phase) in
                    if phase == .background {
                        isUnlocked = false
                        noBiometrics = false
                    }
                }
        }
    }
}
