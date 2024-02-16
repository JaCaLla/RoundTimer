//
//  EMOMTimerListView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 20/1/24.
//

import SwiftUI

struct EMOMTimerListView: View {
    var emoms: [Emom]
    let gridItems = [GridItem](repeating: GridItem(), count: 2)
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 10) {
            ForEach(emoms.indices, id: \.self) { index in
                EMOMTimerView(emom: emoms[index])
            }
        }
    }
}

#Preview {
    EMOMTimerListView(emoms: .sampleEvenList)
}
