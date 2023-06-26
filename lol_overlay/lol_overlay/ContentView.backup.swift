//
//  ContentView.swift
//  lol_overlay
//
//  Created by Matthieu Olenga Disashi on 12/06/2023.
//

import Quartz
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
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the available space
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var timer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        if let window = NSApplication.shared.windows.first {
            window.isOpaque = false
            window.backgroundColor = NSColor.clear

            // Remove the title bar
            window.styleMask = [.borderless, .fullSizeContentView, .titled]

            // Keep the content but make the window background transparent
            window.contentView?.wantsLayer = true
            window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

            // Keep window above all other and ignore mouse events
            window.level = NSWindow.Level.screenSaver
            window.ignoresMouseEvents = true

            // Keep the window on all spaces
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .fullScreenAuxiliary]

            // Set the window size and position
            window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)

            // Set the window size and position
            if let gameWindowFrame = findLeagueOfLegendsWindow() {
                window.setFrame(gameWindowFrame, display: true)
            } else {
                // Fallback to full screen if game window not found
                window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
            }

            // Set up a timer to periodically update the overlay position and size
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self, let gameWindowFrame = self.findLeagueOfLegendsWindow() else {
                    return
                }
            
                print(gameWindowFrame)
                window.setFrame(gameWindowFrame, display: true)
            }
        }
    }

    func findLeagueOfLegendsWindow() -> CGRect? {
        // Get the frontmost application
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }

        print(frontmostApp.localizedName)

        // Check if the frontmost app is League of Legends
        if frontmostApp.localizedName == "League Of Legends" {
            let frontmostAppPID = frontmostApp.processIdentifier

            let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: AnyObject]]

            for window in windowListInfo ?? [] {
                if let ownerPID = window[kCGWindowOwnerPID as String] as? Int {
                    // Check if the window belongs to the frontmost application
                    if ownerPID == frontmostAppPID {
                        if let boundsDict = window[kCGWindowBounds as String] as? [String: CGFloat],
                        let x = boundsDict["X"],
                        let y = boundsDict["Y"],
                        let width = boundsDict["Width"],
                        let height = boundsDict["Height"] {
                            return CGRect(x: x, y: y, width: width, height: height)
                        }
                    }
                }
            }
        }

        return nil
    }
}
