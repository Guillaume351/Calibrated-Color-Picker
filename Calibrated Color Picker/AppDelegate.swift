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
    
    var lastDate = Date()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let calibration = Calibration()
        let settings = UserSettings()
        let contentView = ContentView().environmentObject(mouse).environmentObject(calibration).environmentObject(settings)
        
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
            if(self.lastDate.distance(to: Date()) > 0.05){
                self.lastDate = Date()
                self.mouse.coord.x = self.mouseLocation.x
                self.mouse.coord.y = self.mouseLocation.y
            }
            
            return $0
        }
        
        
        // Clicks outside the window
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.leftMouseDown) { (NSEvent) in
            print("clic outside the window")
            if (calibration.isCalibrating){
                print("while calibrating !")
                calibration.calibrationColor = calibration.lastAverageColor
                calibration.isCalibrated = true
                print("now calibrated. Deltas :", calibration.baseColorForCalibration.redComponent - calibration.lastAverageColor.redComponent)
                
                calibration.isCalibrating = false
            }
            
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}

class MouseCoordinates: ObservableObject {
    @Published var coord = CGPoint(x:0,y:0)
}

class Calibration: ObservableObject {
    // Color expected
    @Published var baseColorForCalibration : NSColor = NSColor.black
    
    // Color you actually picked up
    @Published var calibrationColor : NSColor = NSColor.black
    
    // Used as a buffer value
    var lastAverageColor : NSColor = NSColor.black
    @Published var isCalibrated : Bool = false
    @Published var isCalibrating : Bool = false
}

class UserSettings : ObservableObject {
    @Published var colorMode : ColorMode = ColorMode.RGB
}

