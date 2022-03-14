//
//  wordlefightApp.swift
//  wordlefight
//
//  Created by Ivan Loh on 1/3/22.
//

import SwiftUI

@main
struct wordleFight: App {
    @StateObject var dm = WordleDataModel()
    @StateObject var csManager = ColorSchemeManager()
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(dm)
                .environmentObject(csManager)
                .onAppear {
                    csManager.applyColorScheme()
                }
        }
    }
}
