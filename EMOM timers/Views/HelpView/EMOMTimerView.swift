//
//  EMOMTimerView.swift
//  AppRoundTimer
//
//  Created by Javier Calartrava on 30/3/24.
//

import SwiftUI

struct EMOMTimerView: View {
    let slides: [Slide] = [
        Slide(text: "emom_paragraph_2", image: "apple_watch_apps"),
        Slide(text: "emom_paragraph_3", image: "app_timer_menu"),
        Slide(text: "emom_paragraph_4", image: "app_setup_rounds"),
        Slide(text: "emom_paragraph_5", image: "app_work_time"),
        Slide(text: "emom_paragraph_6", image: "app_rest_time"),
        Slide(text: "emom_paragraph_7", image: "app_emom_work"),
        Slide(text: "emom_paragraph_8", image: "app_emom_rest"),
        Slide(text: "emom_paragraph_9", image: "app_emom_end"),
        Slide(text: "emom_paragraph_10", image: "app_emom_dimmed")
    ]
    var body: some View {
            ParagraphImageView(header: "emom_paragraph_1",
                               slides: slides)
            .padding()
//            .onAppear {
//                TrackingsManager.shared.log(eventName: "EmomTimerView", metadata: ["type": "screenevent"])
//            }
    }
}



#Preview {
    EMOMTimerView()
}
