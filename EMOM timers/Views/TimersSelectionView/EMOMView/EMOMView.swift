//
//  EMOMView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 17/5/24.
//

import SwiftUI

struct EMOMView: View {
    let bottonSideSize = 50.0
    @Environment(\.scenePhase) private var scenePhase
    @Binding var customTimer: CustomTimer?
    @StateObject var emomViewModel = EMOMViewModel()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                closeButton()
            }
            Spacer()
            VStack {
                message()
                HStack {
                    rounds()
                    Spacer()
                    mmss()
                }
            }
            Spacer()
        }
        .onAppear {
            guard emomViewModel.state.value == .notStarted else { return }
            emomViewModel.setAndStart(emom: customTimer)
          //  emomViewModel.action()
        }
        .contentShape(Rectangle())
    }
    
    private func closeButton() -> some View {
        Button(action: {
            emomViewModel.close()
            customTimer = nil
        }, label: {
                Image(systemName: "xmark")
            })
            .modifier(ButtonAW())
    }
    
    private func message() -> some View {
        Text("\(emomViewModel.getCurrentMessage())")
            .foregroundStyle(.white)
            .font(.messageiOSAppFont)
    }
    
    private func rounds() -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text((emomViewModel.getCurrentRound()))
                .font(.timerAndRoundiOSAppFont)
            Text("\(emomViewModel.getRounds())")
                .font(.emomRoundsiOSAppFont)
        } .foregroundColor(.roundColor)
    }
    
    private func mmss() -> some View {
            Text(emomViewModel.mmss)
                .foregroundStyle(emomViewModel.getForegroundTextColor())
                .font(.timerAndRoundiOSAppFont)
    }
}


#Preview("Small Font") {
    let model = EMOMViewModel()
    let customTimer = CustomTimer(timerType: .emom, rounds: 2, workSecs: 1800, restSecs: 0)

    model.setAndStart(emom: customTimer)
    return EMOMView(customTimer: .constant(customTimer))
       // .previewInterfaceOrientation(.landscapeLeft)
        .environmentObject(model)
}

//#Preview("Regular Font") {
//    //let model =  EMOMViewModel()
//   // model.set(emom: CustomTimer(timerType: .emom,rounds: 2, workSecs: 1800, restSecs: 0))
//    return EMOMView(customTimer: .constant(nil))
//        .previewInterfaceOrientation(.landscapeLeft)
//     //   .environmentObject(model)
//}

//#Preview("Large Font") {
//    let model =  EMOMViewModel()
// //   model.set(emom: CustomTimer(timerType: .emom,rounds: 12, workSecs: 200, restSecs: 0))
//    return EMOMView(customTimer: .constant(nil))
//        .previewInterfaceOrientation(.landscapeLeft)
//   //     .environmentObject(model)
//}
