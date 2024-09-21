//
//  UpTimerView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/3/24.
//
import SwiftUI

struct UpTimerView: View {
    let bottonSideSize = 50.0
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Binding var customTimer: CustomTimer?
    @StateObject var upTimerViewModel = UpTimerViewModel()
    @State var gaugeProgress: Double = 0.0
    var body: some View {
        VStack(spacing: 0) {
            if !isLuminanceReduced {
                HStack {
                    Button(action: {
                        upTimerViewModel.close()
                        customTimer = nil
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    .modifier(ButtonAW())
                    Spacer()
                }
            }
            Spacer()
            VStack(spacing: 0) {
                Text("\(upTimerViewModel.getCurrentMessage(customTimer: customTimer))")
                    .font(.messageFont)
                HStack {
                    Text("UP")
                    .foregroundColor(.roundColor)
                    .font(upTimerViewModel.getTimerAndRoundFont())
                    Spacer()
                    VStack {
                        if let chronoOnMove = upTimerViewModel.chronoOnMove,
                           !isLuminanceReduced {
                            Text("\(chronoOnMove, style: .timer)")
                                .foregroundStyle(upTimerViewModel.getForegroundTextColor())
                                .allowsTightening(true)
                        } else {
                            Text(upTimerViewModel.chronoFrozen)
                                .foregroundStyle(upTimerViewModel.getForegroundTextColor())
                        }
                    }
                    .font(upTimerViewModel.getTimerAndRoundFont(isLuminanceReduced: isLuminanceReduced))
                }
                
                Gauge(value: upTimerViewModel.progress, label: { })
                    .tint(.roundColor)
                    .gaugeStyle(.accessoryLinearCapacity)
                    .scaleEffect(x: 1.0, y: 0.25)
            }
            Spacer(minLength: 7)
            if isLuminanceReduced {
                HStack {
                    Image(systemName: "battery.25percent")
                    Text("Screen dimmed. Tap to unblock.")
                }.frame(height: 50)
            } else {
                HStack {
                    HeartZoneView()
                    Spacer()
                }
//                Button(action: {
//                    upTimerViewModel.action()
//                }, label: {
//                        Image(systemName: upTimerViewModel.getActionIcon())
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: bottonSideSize, height: bottonSideSize)
//                    })
//                    .foregroundStyle(upTimerViewModel.actionButtonColor())
//                    .frame(width: bottonSideSize, height: bottonSideSize)
//                    .clipShape(Circle())
            }
            Spacer(minLength: 5)
        }.background(upTimerViewModel.getBackground())
            .onChange(of: upTimerViewModel.progress) {
                gaugeProgress = upTimerViewModel.progress
            }
            .onAppear {
                guard upTimerViewModel.state == .notStarted else { return }
                upTimerViewModel.set(emom: customTimer)
                upTimerViewModel.action()
            }
    }
}



#Preview("Small Font") {
   // let model =  UpTimerViewModel()
    //model.set(emom: CustomTimer(timerType: .emom,rounds: 22, workSecs: 1800, restSecs: 0))
    return UpTimerView(customTimer:.constant(nil))
       // .environmentObject(model)
}

#Preview("Regular Font") {
   // let model =  UpTimerViewModel()
    //model.set(emom: CustomTimer(timerType: .emom,rounds: 2, workSecs: 1800, restSecs: 0))
    return UpTimerView(customTimer:.constant(nil))
        //.environmentObject(model)
}

#Preview("Large Font") {
    //let model =  UpTimerViewModel()
    //model.set(emom: CustomTimer(timerType: .emom,rounds: 12, workSecs: 200, restSecs: 0))
    return UpTimerView(customTimer:.constant(nil))
       // .environmentObject(model)
}
