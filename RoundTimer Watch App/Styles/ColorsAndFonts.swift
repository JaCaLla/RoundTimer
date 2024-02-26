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
    static let timerAndRoundMediumFont =  Font.system(size: 45, weight: .black)
    static let timerAndRoundSmallFont =  Font.system(size: 40, weight: .black)
    static let timerAndRoundLRLargeFont =  Font.system(size: 55 - 20, weight: .black)
    static let timerAndRoundLRMediumFont =  Font.system(size: 45 - 20, weight: .black)
    static let timerAndRoundLRSmallFont =  Font.system(size: 40 - 20, weight: .black)
    static let messageFont =  Font.system(size: 20, weight: .black)
    static let roundInputFont =  Font.system(size: 70, weight: .black)
    static let pickerSelectionFont = Font.system(size: 40, weight: .black)
    static let countDownFont = Font.system(size: 120, weight: .black)
    static let emomRounds = Font.system(size: 25, weight: .black)
}
