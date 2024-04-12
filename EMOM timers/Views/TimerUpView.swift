//
//  TimerUpView.swift
//  AppRoundTimer
//
//  Created by Javier Calartrava on 30/3/24.
//

import SwiftUI

struct TimerUpView: View {
    let slides: [Slide] = [
        Slide(text: "emom_paragraph_2", image: "apple_watch_apps"),
        Slide(text: "timerup_paragraph_3", image: "app_timer_menu"),
        Slide(text: "emom_paragraph_7", image: "uptimer_work"),
        Slide(text: "emom_paragraph_8", image: "uptimer_finished"),
        Slide(text: "emom_paragraph_10", image: "app_emom_dimmed")
    ]
    var body: some View {
            ParagraphImageView(header: "timerup_paragraph_1",
                               slides: slides)
            .padding()
    }
}

#Preview {
    TimerUpView()
}
