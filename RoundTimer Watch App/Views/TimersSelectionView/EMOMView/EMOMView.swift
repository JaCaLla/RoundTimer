import SwiftUI

struct EMOMView: View {
    let bottonSideSize = 50.0
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    //@EnvironmentObject var emomViewModel: EMOMViewModel
    @Binding var customTimer: CustomTimer?
    @StateObject var emomViewModel = EMOMViewModel()
    var body: some View {
        VStack(spacing: 0) {
            if !isLuminanceReduced {
                HStack {
                    Button(action: {
                        emomViewModel.close()
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
                Text("\(emomViewModel.getCurrentMessage())")
                    .font(.messageFont)
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("\(emomViewModel.getCurrentRound())")
                            .foregroundColor(.roundColor)
                        Text("\(emomViewModel.getRounds())")
                            .font(.emomRounds)
                            .foregroundColor(.roundColor)
                    }
                    .font(emomViewModel.getTimerAndRoundFont())
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
                    .font(emomViewModel.getTimerAndRoundFont(isLuminanceReduced: isLuminanceReduced))
                }
                
                Gauge(value: emomViewModel.getRoundsProgress(), label: { })
                    .tint(.roundColor)
                    .gaugeStyle(.accessoryLinearCapacity)
                    .scaleEffect(x: 1.0, y: 0.25)
            }
            Spacer(minLength: 7)
        //    HStack(spacing: 5) {
            if isLuminanceReduced {
                HStack {
                    Image(systemName: "battery.25percent")
                    Text("Screen dimmed. Tap to unblock.")
                }.frame(height: 50)
            } else {
                Button(action: {
                    emomViewModel.action()
                }, label: {
                        Image(systemName: emomViewModel.getActionIcon())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: bottonSideSize, height: bottonSideSize)
                    })
                    .foregroundStyle(emomViewModel.actionButtonColor())
                    .frame(width: bottonSideSize, height: bottonSideSize)
                    .clipShape(Circle())
            }

       //     }
            Spacer(minLength: 15 - 10)
        }.background(emomViewModel.getBackground())
            .onChange(of: scenePhase) { print($0) }
            .onAppear {
                guard emomViewModel.state == .notStarted else { return }
                emomViewModel.set(emom: customTimer)
                emomViewModel.action()
            }
//        .overlay {
//            if emomViewModel.showCountDownView {
//                CountdownView {
//                    //model.showCountDownView = false
//                    emomViewModel.startWorkTime()
//                }
//            }
//        }
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
   // let model =  EMOMViewModel()
  //  model.set(emom: CustomTimer(timerType: .emom,rounds: 22, workSecs: 1800, restSecs: 0))
    return EMOMView(customTimer: .constant(nil))
    //    .environmentObject(model)
}

#Preview("Regular Font") {
    //let model =  EMOMViewModel()
   // model.set(emom: CustomTimer(timerType: .emom,rounds: 2, workSecs: 1800, restSecs: 0))
    return EMOMView(customTimer: .constant(nil))
     //   .environmentObject(model)
}

#Preview("Large Font") {
    let model =  EMOMViewModel()
 //   model.set(emom: CustomTimer(timerType: .emom,rounds: 12, workSecs: 200, restSecs: 0))
    return EMOMView(customTimer: .constant(nil))
   //     .environmentObject(model)
}
