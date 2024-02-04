//
//  EMOMView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 21/1/24.
//

import SwiftUI

struct EMOMView: View {
    @EnvironmentObject var emomViewModel: EMOMViewModel
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    emomViewModel.close()
                }, label: {
                        Image(systemName: "xmark")
                    })
                    .modifier(ButtonAW())
                Spacer()
            }
            Spacer()
            VStack(spacing: -10) {
                HStack {
                    if emomViewModel.hasToShow() {
                        Text("WORK")
                    }
                    Spacer()
                    if emomViewModel.hasToShow(work: false) {
                        Text("REST")
                    }
                }
                //.background(.red)
                .frame(height: 10)
                .font(.system(size: 10, weight: .black))
                HStack {
                    if !emomViewModel.isTrailingChronoAlignment() {
                        Spacer()
                    }
                    Text("\(emomViewModel.chrono)")
                        .foregroundStyle(emomViewModel.getForegroundTextColor())
                        .font(.system(size: 50, weight: .black))
                        .scaleEffect(emomViewModel.isPaused ? 2.0 : 1.0)
                                        .animation(Animation.easeInOut(duration: 0.5).reverse(on: $emomViewModel.isPaused, delay: 0.5))
                    if emomViewModel.isTrailingChronoAlignment() {
                        Spacer()
                    }
                }
                Gauge(value: emomViewModel.percentage, label: { })
                    .gaugeStyle(.accessoryLinearCapacity)
                    .scaleEffect(x: 1.0, y:0.25)
            }
            HStack(alignment: .top) {
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("TIME CAP")
                                .font(.system(size: 10, weight: .black))
                            Text("\(emomViewModel.getPending())")
                                .font(.system(size: 15, weight: .black))
                        }
                        Spacer()
                    }
                    Spacer()
                }
                Divider().frame(width: 1)
                VStack {
                    Text("ROUNDS")
                        .font(.system(size: 10, weight: .black))
                    Gauge(value: Double(emomViewModel.getCurrentRound()) / Double((emomViewModel.emom?.rounds ?? Int(1.0))), label: {
                            Text("\(emomViewModel.getCurrentRound())/\(emomViewModel.emom?.rounds ?? 1)")
                        }
                    ).gaugeStyle(.accessoryCircularCapacity)
                      Spacer()
                }
                //.background(.red)
                //.frame(width: 80)
            }
            .frame(height: 70)
            //Spacer()
            Divider()
            Spacer(minLength: 7)
            HStack {
                //Spacer(minLength: 50)
                Button(action: {
                    emomViewModel.start()
                 //   isBouncing = true
                }, label: {
                        Image(systemName: emomViewModel.playPause)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                      //  .offset(x: 3, y: 0)
                        
                    })
                    //.modifier(ButtonAW())
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                    

            //    Spacer()
            }
            Spacer(minLength: 15)
        }
            .background(emomViewModel.background)
            .padding(3)
    }

    struct ButtonAW: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(width: 25, height: 25)
                .foregroundColor(Color.white)
            //.background(Color.red)
            .clipShape(Circle())
        }
    }
}

extension Animation {
    func reverse(on: Binding<Bool>, delay: Double) -> Self {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            on.wrappedValue = false /// Switch off after `delay` time
        }
        return self
    }
}

#Preview {
    Group {
        EMOMView()
            .environmentObject(EMOMViewModel())
    }

}
