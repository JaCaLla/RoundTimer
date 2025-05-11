//
//  TimerSelectionView.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 28/7/24.
//

import SwiftUI

struct TimerSelectionView/*<T: View>*/: View {
    let systemName: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?
    let action: () -> Void
    
    init(systemName: String = "timer",
         title: LocalizedStringKey,
         subtitle: LocalizedStringKey? = nil,
         action: @escaping () -> Void) {
        
        self.systemName = systemName
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var tap: some Gesture {
         TapGesture(count: 1).onEnded { _ in self.action() }
     }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: systemName)
                    .resizable()
                    .foregroundColor(.electricBlue)
                    .frame(width: 20.0, height: 20.0)
                Text(title)
                    .font(.buttonTitleFont)
            }
            if let subtitle {
                Divider()
                Text(subtitle)
                    .font(.buttonSubtitleFont)
            }
        }
        .padding()
        .background(.gray10)
        .cornerRadius(8.0)
        .gesture(tap)
    }
    
}

