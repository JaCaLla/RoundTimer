//
//  ParagraphImageView.swift
//  AppRoundTimer
//
//  Created by Javier Calartrava on 5/4/24.
//

import SwiftUI

struct ParagraphImageView: View {
    let header: LocalizedStringKey
    let slides: [Slide]
    var body: some View {
        ScrollView {
            Text(header)
            ForEach(slides, id: \.image) { slide in
                VStack {
                    Image(slide.image)
                        .screenShootModifier()
                    Text(slide.text)
                }
            }
        }
    }
}
