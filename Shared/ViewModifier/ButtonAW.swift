//
//  ButtonAW.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 8/7/24.
//

import SwiftUI

struct ButtonAW: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 25, height: 25)
            .foregroundColor(Color.white)
            .clipShape(Circle())
    }
}