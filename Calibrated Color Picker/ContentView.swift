//
//  ContentView.swift
//  Calibrated Color Picker
//
//  Created by Guillaume Claverie on 11/11/2020.
//

import SwiftUI
import AppKit


struct ContentView: View {
    
    @EnvironmentObject var mouse : MouseCoordinates
    
    // Slider values
    @State var sliderValue = 10.0
    var minimumValue = 0.0
    var maximumvalue = 100.0
    
    var body: some View {
        
        
        // Spacers needed to make the VStack occupy the whole screen
        return HStack{
            if let image = getImageAroundMouse(){
        
                Rectangle()
                    .fill(Color(image.averageColor!))
                    .frame(width: 100, height: 100)
                    .padding()
               
                VStack {
                    Spacer()
                    Text("R: \(image.averageColor!.redComponent * 255)")
                    Text("G: \(image.averageColor!.greenComponent * 255)")
                    Text("B: \(image.averageColor!.blueComponent * 255)")
                    Spacer()
                    Text("L: \(image.averageColor!.rgbColor()!.toLAB().l)")
                    Text("A: \(image.averageColor!.rgbColor()!.toLAB().a)")
                    Text("B: \(image.averageColor!.rgbColor()!.toLAB().b)")
                    Spacer()
                    Slider(value: $sliderValue, in: minimumValue...maximumvalue)
                  //  Text("Coordonnées : \(mouse.coord.x), \(mouse.coord.y)")
                }
                
                Image(nsImage: image)
                    .padding()
                
         
                
            }
        
            
        }
        .border(Color.green)
        .frame(width: 400, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .contentShape(Rectangle()) // Make the entire VStack tappabable, otherwise, only the areay with text generates a gesture
        .onAppear(perform: {
            let cursor = NSCursor.crosshair
            cursor.set()
        })
        
        
    }
    
    func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = mouse.coord
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        
        return screenWithMouse
    }
    
    
    func getImageAroundMouse() -> NSImage? {
        var imageReturned : NSImage?
        if let screen = getScreenWithMouse(){
            let deviceDescription = screen.deviceDescription
            let screenID = deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")]
            
            let size = sliderValue
            var origin = mouse.coord
            origin.y = screen.frame.height - origin.y
            print("Rectangle center : \(origin)")
            origin.x -= CGFloat(size/2)
            origin.y -= CGFloat(size/2)
      
            print("Mouse : \(mouse.coord)")
            print("Min max \(screen.frame.maxY)")
            
            if let image:CGImage = CGDisplayCreateImage(CGMainDisplayID(), rect: CGRect(origin: origin, size: CGSize(width: size, height: size)))
            {
                imageReturned = NSImage(cgImage: image, size: CGSize(width: 100, height: 100))
                
                
                let color = imageReturned!.averageColor!
                
                
                // print the RGB values
                let red = color.redComponent, green = color.greenComponent, blue = color.blueComponent
            //    print("r:", Int(red * 255), " g:", Int(green * 255), " b:", Int(blue * 255))
                
            }
        }
        return imageReturned
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension NSImage {
    /// Returns the average color that is present in the image.
    var averageColor: NSColor? {
        // Image is not valid, so we cannot get the average color
        if !isValid {
            return nil
        }
        
        // Create a CGImage from the NSImage
        var imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let cgImageRef = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        
        // Create vector and apply filter
        let inputImage = CIImage(cgImage: cgImageRef!)
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector])
        let outputImage = filter!.outputImage!
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return NSColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
