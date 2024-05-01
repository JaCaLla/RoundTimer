//
//  Image.swift
//  AppRoundTimer
//
//  Created by Javier Calartrava on 5/4/24.
//

import SwiftUI

extension Image {
    func screenShootModifier() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200)
    }
}
