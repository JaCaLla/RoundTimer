//
//  MainView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 15/5/24.
//

import SwiftUI

struct MainView: View {
    @State var customTimer: CustomTimer?
    var body: some View {
        ZStack {
            if let customTimer {
                EMOMView(customTimer: $customTimer)
                    .forceRotation(orientation: .landscape)
                    
            } else {
                TabView {
                    TimersSelectionView(customTimer: $customTimer)
                        .tabItem {
                            Text("Timers")
                        }
                    HelpView()
                        .tabItem {
                            Text("Help")
                        }
                }
            }
        }

    }
}

#Preview {
    MainView()
}
