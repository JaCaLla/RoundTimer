//
//  Colors.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 9/2/24.
//

import SwiftUI

extension Color {
    static let roundColor = Color("ElectricBlue")
    static let timerStartedColor =  Color("ElectricRed")
    static let timerNotStartedColor = Color("Gray")
    static let timerRestStartedColor = Color("ElectricYellow")
    static let timerFinishedBackgroundColor = Color("ElectricRedBack")
    static let buttonTextColor = Color("White")
    static let paragrahColor = Color(.white)
    static let defaultBackgroundColor = Color(.black)
}

extension Font {
    static let timerAndRoundLargeFont =  Font.system(size: 50, weight: .black)
    static let timerAndRoundMediumFont =  Font.system(size: 45, weight: .black)
    static let timerAndRoundSmallFont =  Font.system(size: 40, weight: .black)
    static let timerAndRoundLRLargeFont =  Font.system(size: 30, weight: .black)
    static let timerAndRoundLRMediumFont =  Font.system(size: 20, weight: .black)
    static let timerAndRoundLRSmallFont =  Font.system(size: 15, weight: .black)
    static let messageFont =  Font.system(size: 20, weight: .black)
    static let roundInputFont =  Font.system(size: 70, weight: .black)
    static let pickerSelectionFont = Font.system(size: 40, weight: .black)
    static let countDownFont = Font.system(size: 120, weight: .black)
    static let emomRounds = Font.system(size: 25, weight: .black)
    static let paragraph = Font.system(size: 25, weight: .black)
    
    static let timerAndRoundiOSAppFont =  Font.system(size: 175, weight: .black)
    static let emomRoundsiOSAppFont = Font.system(size: 80, weight: .black)
    static let messageiOSAppFont =  Font.system(size: 40, weight: .black)
    static let buttoniOSAppFont =  Font.system(size: 40, weight: .black)
}
