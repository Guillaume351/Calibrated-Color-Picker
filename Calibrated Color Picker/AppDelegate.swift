//
//  AppDelegate.swift
//  Calibrated Color Picker
//
//  Created by Guillaume Claverie on 11/11/2020.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    var mouse : MouseCoordinates = MouseCoordinates()
    
    var mouseLocation: NSPoint { NSEvent.mouseLocation }
    var location: NSPoint { window.mouseLocationOutsideOfEventStream }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(mouse)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        
        
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            self.mouse.coord.x = self.mouseLocation.x
            self.mouse.coord.y = self.mouseLocation.y
                 return $0
             }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

class MouseCoordinates: ObservableObject {
    @Published var coord = CGPoint(x:0,y:0)
}

