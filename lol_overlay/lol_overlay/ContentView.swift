//
//  ContentView.swift
//  lol_overlay
//
//  Created by Matthieu Olenga Disashi on 12/06/2023.
//

import SwiftUI
import CoreGraphics

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
    var accessibilityObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        enableAccessibilityPermissions()

        if let window = NSApplication.shared.windows.first {
            self.window = window
            setupOverlayWindow()
            startTimer()
        }
    }

    func enableAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)
        accessibilityObserver = DistributedNotificationCenter.default().addObserver(forName: .init("com.apple.accessibility.api"), object: nil, queue: .main) { [weak self] _ in
            self?.setupOverlayWindow()
        }
    }

    func setupOverlayWindow() {
        window.isOpaque = false
        window.backgroundColor = NSColor.clear

        // Remove the title bar
        window.styleMask = [.borderless, .fullSizeContentView, .titled]

        // Keep the content but make the window background transparent
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

        // Keep window above all others and ignore mouse events
        window.level = .floating
        window.ignoresMouseEvents = true

        // Keep the window on all spaces
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary, .fullScreenAuxiliary]

        // Set the initial window position and size
        window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let gameWindowFrame = self.findLeagueOfLegendsWindow() else {
                return
            }

            self.window.setFrame(gameWindowFrame, display: true)
        }
    }

    func findLeagueOfLegendsWindow() -> CGRect? {
        // Get the frontmost application
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }

        print(frontmostApp.localizedName)

        // Check if the frontmost app is League of Legends
        if frontmostApp.localizedName == "League of Legends" {
            let frontmostAppPID = frontmostApp.processIdentifier

            let options = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements)
            guard let windowListInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
                return nil
            }

            for window in windowListInfo {
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
