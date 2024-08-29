//
//  buttonStyle.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 8/7/24.
//

import SwiftUI

extension View {
    func buttonStyle() -> some View {
        modifier(ButtonStyle())
    }
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.buttoniOSAppFont)
                .padding()
                .foregroundStyle(Color.buttonTextColor)
                .background(Color.roundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/*
 extension View {
     func buttonAWStyle() -> some View {
         modifier(ButtonAW())
     }
 }

 struct ButtonAW: ViewModifier {
     func body(content: Content) -> some View {
         content
             .frame(width: 25, height: 25)
             .foregroundColor(Color.white)
             .clipShape(Circle())
     }
 }
 */
