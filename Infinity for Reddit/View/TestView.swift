//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI
import Kingfisher

struct TestView: View {
    var body: some View {
        VStack {
            KFAnimatedImage(URL(string: "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExaHo0bm5ieG81YWw1ZWd0NzgwaXFscDRjc3JreTlnd2s4cGFkZ2hiYyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/2D8g2rXcWx1DO/giphy.gif"))
                .configure { view in
                    view.contentMode = .scaleAspectFit   // .resizable().scaledToFit()
                }
                .frame(width: 200, height: 200)

            KFAnimatedImage(URL(string: "https://preview.redd.it/mymedia-2-0-released-open-source-app-written-purely-in-v0-lu431bo885sf1.png?width=1080&crop=smart&auto=webp&s=5b8e2d5f1dcf6b0462b6750343e6dfa6c3402f09"))
                .configure { view in
                    view.contentMode = .scaleAspectFill  // .resizable()
                    view.clipsToBounds = true
                }
                .frame(width: 200, height: 200)
        }
    }
}
