//
//  ContentView.swift
//  lol_overlay
//
//  Created by Matthieu Olenga Disashi on 12/06/2023.
//

import SwiftUI
struct ContentView: View {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        if let window = NSApplication.shared.windows.first {
            window.isOpaque = false
            window.backgroundColor = NSColor.clear

            // Remove the title bar
            window.styleMask = [.borderless, .fullSizeContentView]

            // Keep the content but make the window background transparent
            window.contentView?.wantsLayer = true
            window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

            // Keep window above all other and ignore mouse events
            window.level = .floating
            window.ignoresMouseEvents = true

            // Keep the window on all spaces
            window.collectionBehavior = [.fullScreenPrimary]

            NSApp.setActivationPolicy(.accessory)
        }
    }
}
