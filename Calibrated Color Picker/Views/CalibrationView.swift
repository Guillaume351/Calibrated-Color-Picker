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
                Form {
                    Section(header: Text(settings.colorMode == ColorMode.RGB ? "R" : "L").bold()) {
                        TextField("",text: $val1)
                    }
                    Section(header: Text(settings.colorMode == ColorMode.RGB ? "G" : "A").bold()) {
                        TextField("",text: $val2)
                    }
                    Section(header: Text(settings.colorMode == ColorMode.RGB ? "B" : "B").bold()) {
                        TextField("", text: $val3)
                    }
                }.padding()
                Spacer()
            }
        }
    }
}

struct CalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationView()
    }
}
