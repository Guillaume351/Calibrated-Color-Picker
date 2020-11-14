//
//  ContentView.swift
//  Calibrated Color Picker
//
//  Created by Guillaume Claverie on 11/11/2020.
//

import SwiftUI
import AppKit


struct ContentView: View {
    
    // Used to transfer mouse coordinates and move events
    @EnvironmentObject var mouse : MouseCoordinates
    
    // Used to store calibrated RGB value
    @EnvironmentObject var calibration : Calibration
    
    @EnvironmentObject var settings : UserSettings
    
    //  var averageColor : NSColor = NSColor.black
    // Slider values
    @State var sliderValue = 10.0
    var minimumValue = 0.0
    var maximumvalue = 100.0
    @State var modeSelected = ColorMode.RGB
    
    @State var showCalibration = false
    
    var body: some View {
        
        
        // Spacers needed to make the VStack occupy the whole screen
        return VStack {

            
            Picker("Mode", selection: $modeSelected) {
                Text("RGB").tag(ColorMode.RGB)
                Text("LAB").tag(ColorMode.LAB)
            }.onReceive([modeSelected].publisher.first(), perform: { _ in
              //  settings.colorMode = modeSelected
                if(settings.colorMode != modeSelected){
                    settings.colorMode = modeSelected
                    print("Mode changed to " + modeSelected.rawValue)
                }
            }).padding()
            HStack{
                if let (image, color) = getImageAroundMouse(){
                    if let color = color {
                        Rectangle()
                            .fill(Color(color))
                            .frame(width: 100, height: 100)
                            .padding()
                        
                        VStack {
                            Spacer()
                            if(modeSelected == ColorMode.RGB){
                                Text("R: \(color.redComponent * 255)")
                                Text("G: \(color.greenComponent * 255)")
                                Text("B: \(color.blueComponent * 255)")
                            }else{
                                if let rgbColor = color.rgbColor() {
                                    Text("L: \(String(format: "%.2f", rgbColor.toLAB().l))"
                                    + "\nA: \(String(format: "%.2f", rgbColor.toLAB().a))"
                                    + "\nB: \(String(format: "%.2f",  rgbColor.toLAB().b))"
                                    )
                                }
                           
                               
                            }
                            Spacer()
                        }
                        
                    }else{
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .padding()
                        VStack {
                            Spacer()
                            Text("Déplacez la souris pour commencer")
                            Spacer()
                        }
                    }
                    
                    if let image = image {
                        Image(nsImage: image)
                            .padding()
                    }else{
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .padding()
                    }
                }
                
            }
            HStack{
                Spacer()
                Slider(value: $sliderValue, in: minimumValue...maximumvalue)
                Spacer()
                Button {
                    //Actions
                    withAnimation {
                        showCalibration.toggle()
                    }
                    
                } label: {
                    Text("Calibrer")
                }
                
            }.padding()
            
            if showCalibration{
                CalibrationView().environmentObject(calibration).environmentObject(settings).transition(.scale)
            }
            
        }
       // .border(Color.green)
        .frame(width: 400, height: showCalibration ? 450 : 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
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
    
    
    func getImageAroundMouse() -> (NSImage?, NSColor?){
        var imageReturned : NSImage?
        var colorReturned : NSColor?
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
                
                colorReturned = imageReturned!.averageColor!
                colorReturned!.usingColorSpace(.sRGB)
                
                if(calibration.isCalibrating){
                    calibration.lastAverageColor = colorReturned!
                }
                
                if(calibration.isCalibrated){
                    let red = colorReturned!.redComponent, green = colorReturned!.greenComponent, blue = colorReturned!.blueComponent
                    
                    let deltaR = calibration.baseColorForCalibration.redComponent - calibration.calibrationColor.redComponent
                    let deltaG = calibration.baseColorForCalibration.greenComponent - calibration.calibrationColor.greenComponent
                    let deltaB = calibration.baseColorForCalibration.blueComponent - calibration.calibrationColor.blueComponent
                    
                    if #available(OSX 11.0, *) {
                        //TODO find for older versions
                        // averageColor = NSColor(Color(.sRGB,red: Double(red + deltaR), green: Double(green + deltaG), blue: Double(blue + deltaB), opacity: 1))
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                // print the RGB values
                //  let red = color.redComponent, green = color.greenComponent, blue = color.blueComponent
                //    print("r:", Int(red * 255), " g:", Int(green * 255), " b:", Int(blue * 255))
                
            }
        }
        return (imageReturned, colorReturned)
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

enum ColorMode: String, CaseIterable, Identifiable{
    case RGB
    case LAB
    
    var id: String {self.rawValue}
}
