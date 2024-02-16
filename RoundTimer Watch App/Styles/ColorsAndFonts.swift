//
//  Colors.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 9/2/24.
//

import SwiftUI

extension Color {
    static let roundColor = Color("ElectricRed")
    static let timerStartedColor = Color("ElectricBlue")
    static let timerNotStartedColor = Color("Gray")
    static let timerRestStartedColor = Color("ElectricYellow")
    
    static let timerFinishedBackgroundColor = Color("ElectricRedBack")
    
}

extension Font {
    static let timerAndRoundLargeFont =  Font.system(size: 55, weight: .black)
    static let timerAndRoundMediumFont =  Font.system(size: 47, weight: .black)
    static let timerAndRoundSmallFont =  Font.system(size: 40, weight: .black)
    static let messageFont =  Font.system(size: 20, weight: .black)
    static let roundInputFont =  Font.system(size: 70, weight: .black)
    static let pickerSelectionFont = Font.system(size: 40, weight: .black)
    
}
