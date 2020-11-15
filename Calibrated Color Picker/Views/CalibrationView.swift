//
//  CalibrationView.swift
//  Calibrated Color Picker
//
//  Created by Guillaume Claverie on 14/11/2020.
//

import SwiftUI

struct CalibrationView: View {
    var rgbMode = true
    
    @State private var val1: String = "" //R - L
    @State private var val2: String = "" //G - A
    @State private var val3: String = "" //B - B
    
    @EnvironmentObject var calibration : Calibration
    @EnvironmentObject var settings : UserSettings
    
    
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                HStack {
                    Text(settings.colorMode == ColorMode.RGB ? "R" : "L").bold()
                    TextField("",text: $val1)
                    
                    Text(settings.colorMode == ColorMode.RGB ? "G" : "A").bold()
                    TextField("",text: $val2)
                    
                    Text(settings.colorMode == ColorMode.RGB ? "B" : "B").bold()
                    TextField("", text: $val3)
                    
                }.padding()
                Spacer()
                
            }
            HStack{
                
                
                Button (action: {
                    if let val1AsDouble = Double(val1) {
                        if let val2AsDouble = Double(val2) {
                            if let val3AsDouble = Double(val3) {
                                print("Calibrating with ", val1, val2, val3)
                                var color : NSColor
                                if settings.colorMode == .RGB {
                                    color = NSColor(red: CGFloat(val1AsDouble/255), green: CGFloat(val2AsDouble/255), blue: CGFloat(val3AsDouble/255), alpha: CGFloat(1))
                                }else{
                                    var labColor : LABColor = LABColor(l: CGFloat(val1AsDouble), a: CGFloat(val2AsDouble), b: CGFloat(val3AsDouble), alpha: CGFloat(1))
                                    color = (labColor.toRGB().color())
                                }
                                color.usingColorSpace(.sRGB)
                                calibration.baseColorForCalibration = color
                                print("Base color set")
                                calibration.isCalibrating = true
                                print("isCalibrating activated")
                                
                            }
                        }
                    }
                }) {
                    
                    Text("Valider")
                }
                
                
                Button (action: {
                    calibration.isCalibrated = false
                    calibration.isCalibrating = false
                }) {
                    
                    Text("Reset")
                }
            }.frame(width: 300, height: 50, alignment: .center)
            
        }
    }
}

struct CalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationView()
    }
}
