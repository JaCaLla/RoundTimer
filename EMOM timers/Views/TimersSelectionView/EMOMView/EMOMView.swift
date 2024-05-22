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
   // @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Binding var customTimer: CustomTimer?
    @StateObject var emomViewModel = EMOMViewModel()

    var body: some View {
        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    emomViewModel.close()
                                    customTimer = nil
                                }, label: {
                                    Image(systemName: "xmark")
                                })
                                .modifier(ButtonAW())
                                
                            }
            Spacer()
            VStack {
                Text("\(emomViewModel.getCurrentMessage())")
                    .foregroundStyle(.white)
                                    .font(.messageiOSAppFont)
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                      Text((emomViewModel.getCurrentRound()))
                            .font(.timerAndRoundiOSAppFont)
                        Text("\(emomViewModel.getRounds())")
                                    .font(.emomRoundsiOSAppFont)
                     // Spacer()
                    } .foregroundColor(.roundColor)
                    Spacer()
                        VStack {
                            if let chronoOnMove = emomViewModel.chronoOnMove {
                                Text("\(chronoOnMove, style: .timer)")
                                    .foregroundStyle(emomViewModel.getForegroundTextColor())
                                    .allowsTightening(true)
                            } else {
                                Text(emomViewModel.chronoFrozen)
                                    .foregroundStyle(emomViewModel.getForegroundTextColor())
                            }
                        }
                     //   .font(emomViewModel.getTimerAndRoundFont(isLuminanceReduced: false))
    //                    .foregroundColor(.timerStartedColor)
                        .font(.timerAndRoundiOSAppFont)
                }
            }
            Spacer()
        }
                    .onAppear {
                        guard emomViewModel.state == .notStarted else { return }
                        emomViewModel.set(emom: customTimer)
                        emomViewModel.action()
                    }
        .background(emomViewModel.getBackground())
        .contentShape(Rectangle())
        .onTapGesture {
            emomViewModel.action()
        }
        
        //        VStack(spacing: 0) {
//           // if !isLuminanceReduced {
//                HStack {
//                    Button(action: {
//                        emomViewModel.close()
//                        customTimer = nil
//                    }, label: {
//                        Image(systemName: "xmark")
//                    })
//                    .modifier(ButtonAW())
//                    Spacer()
//                }
//           // }
//            Spacer()
//            VStack(spacing: 0) {
//                Text("\(emomViewModel.getCurrentMessage())")
//                    .font(.messageFont)
//                HStack {
//                    HStack(alignment: .firstTextBaseline, spacing: 0) {
//                        Text("\(emomViewModel.getCurrentRound())")
//                            .foregroundColor(.roundColor)
//                        Text("\(emomViewModel.getRounds())")
//                            .font(.emomRounds)
//                            .foregroundColor(.roundColor)
//                    }
//                    .font(emomViewModel.getTimerAndRoundFont())
//                    Spacer()
//                    VStack {
//                        if let chronoOnMove = emomViewModel.chronoOnMove {
//                            Text("\(chronoOnMove, style: .timer)")
//                                .foregroundStyle(emomViewModel.getForegroundTextColor())
//                                .allowsTightening(true)
//                        } else {
//                            Text(emomViewModel.chronoFrozen)
//                                .foregroundStyle(emomViewModel.getForegroundTextColor())
//                        }
//                    }
//                    .font(emomViewModel.getTimerAndRoundFont(isLuminanceReduced: false))
//                }
//                
//                Gauge(value: emomViewModel.getRoundsProgress(), label: { })
//                    .tint(.roundColor)
//                    .gaugeStyle(.accessoryLinearCapacity)
//                    .scaleEffect(x: 1.0, y: 0.25)
//            }
//            Spacer(minLength: 7)
//            Button(action: {
//                emomViewModel.action()
//            }, label: {
//                    Image(systemName: emomViewModel.getActionIcon())
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: bottonSideSize, height: bottonSideSize)
//                })
//                .foregroundStyle(emomViewModel.actionButtonColor())
//                .frame(width: bottonSideSize, height: bottonSideSize)
//                .clipShape(Circle())
//            Spacer(minLength: 15 - 10)
//        }.background(.green) //emomViewModel.getBackground())
//            .onChange(of: scenePhase) { print($0) }
//            .onAppear {
//                guard emomViewModel.state == .notStarted else { return }
//                emomViewModel.set(emom: customTimer)
//                emomViewModel.action()
//            }
            
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



#Preview("Small Font") {
    let model =  EMOMViewModel()
    let customTimer = CustomTimer(timerType: .emom,rounds: 2, workSecs: 1800, restSecs: 0)
    
    model.set(emom:customTimer )
    return EMOMView(customTimer: .constant(customTimer))
        .previewInterfaceOrientation(.landscapeLeft)
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
