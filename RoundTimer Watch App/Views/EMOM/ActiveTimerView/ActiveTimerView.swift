//
//  ContentView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

struct ActiveTimerView: View {
    @State private var isPresentingNewRoundTimerView = false
    @State var selectedEMOM: Emom?
    @StateObject var contentModel = EMOMViewModel()
    var body: some View {
        VStack(spacing: 0) {
            if let emom = contentModel.emom {
                EMOMView()
                    .environmentObject(contentModel)
            }
            else {
                NavigationView {
                    VStack(spacing: 20) {
                        Button(action: {
                            isPresentingNewRoundTimerView.toggle()
                        }, label: {
                                Image(systemName: "timer")
                                .resizable()
                                .foregroundColor(.electricBlue)
                                .frame(width: 50.0, height: 50.0)
                            })
                        .frame(width: 70.0, height: 70.0)
                        .clipShape(Circle())
                        Text("No active EMOM!")
                            .foregroundColor(.electricRed)
                            .font(.messageFont)
                            .fullScreenCover(isPresented: $isPresentingNewRoundTimerView) {
                            SelectEMOMView(emom: $selectedEMOM)
                        }
                    }
                        .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                isPresentingNewRoundTimerView.toggle()
                            }, label: {
                                    Image(systemName: "plus")
                                    .foregroundColor(.electricRed)
                                })
                        }
                    }
                }
            }
        }
        .onChange(of: selectedEMOM) {
            guard let selectedEMOM else { return }
            contentModel.set(emom: selectedEMOM)
            self.selectedEMOM = nil
        }
    }
}

#Preview {
    ActiveTimerView()
}

#Preview {
    ActiveTimerView(selectedEMOM: .sample16rounds50Work10Rest)
}

extension Emom {
    static let sample1rounds1Work0Rest = Emom(rounds: 1, workSecs: 1, restSecs: 0)
    static let sample1rounds5Work0Rest = Emom(rounds: 1, workSecs: 5, restSecs: 0)
    static let sample2rounds5Work5Rest = Emom(rounds: 2, workSecs: 5, restSecs: 5)
    static let sample2rounds5Work0Rest = Emom(rounds: 2, workSecs: 5, restSecs: 0)
    static let sample1rounds30Work0Rest = Emom(rounds: 1, workSecs: 30, restSecs: 0)
    static let sample2rounds30Work0Rest = Emom(rounds: 2, workSecs: 30, restSecs: 0) // pass
    static let sample3rounds60Work0Rest = Emom(rounds: 3, workSecs: 60, restSecs: 0)
    static let sample15rounds60Work0Rest = Emom(rounds: 15, workSecs: 60, restSecs: 0)
    
    static let sample1rounds10Work0Rest = Emom(rounds: 1, workSecs: 10, restSecs: 0)
    static let sample1rounds30Work30Rest = Emom(rounds: 1, workSecs: 30, restSecs: 30)
    static let sample16rounds50Work10Rest = Emom(rounds: 16, workSecs: 50, restSecs: 10)
    static let sample10rounds3720Work10Rest = Emom(rounds: 10, workSecs: 3720, restSecs: 10)
}

extension Array where Element == Emom {
    static var sampleEvenList: [Emom] = [.sample1rounds10Work0Rest,
            .sample1rounds30Work30Rest,
            .sample16rounds50Work10Rest,
            .sample10rounds3720Work10Rest]
    static var sampleOddList: [Emom] = [.sample1rounds10Work0Rest,
            .sample1rounds30Work30Rest,
            .sample16rounds50Work10Rest]

}
