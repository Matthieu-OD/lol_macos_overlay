//
//  lol_overlayApp.swift
//  lol_overlay
//
//  Created by Matthieu Olenga Disashi on 12/06/2023.
//

import SwiftUI

@main
struct lol_overlayApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
