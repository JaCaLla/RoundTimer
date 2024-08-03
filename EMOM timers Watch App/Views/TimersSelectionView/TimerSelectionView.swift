//
//  TimerSelectionView.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 28/7/24.
//

import SwiftUI

struct TimerSelectionView<T: View>: View {
    let action: () -> Void
    let label: ()->T
    
    
    init(action: @escaping () -> Void, @ViewBuilder label: @escaping ()->T) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        VStack {
            Text("Title")
                .font(.largeTitle)
            Text("Subtitle")
                .font(.title2)
        }
        .navigationTitle("Card Detail")
//        Button(action: {
//            action()
//        }, label: {
//            label()
//        })
    }
    
}

