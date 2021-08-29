//
//  CardRandomizer.swift
//  CardRandomizer
//
//  Created by Michael Horowitz on 8/28/21.
//

import SwiftUI

struct CardRandomizer: View {
  @State private var currentCard = ["RED_BACK"]
  @State private var animationAmount: CGFloat = 1
  @EnvironmentObject var preferences: UserPreferences
  @State private var cardCount = 1
  let columns: [GridItem] = [GridItem(.flexible())]
    var body: some View {
      ZStack {
        VStack {
          Text("Card Count: \(cardCount)")
            .font(.system(.title, design: .rounded))
            .fontWeight(.medium)
          Stepper("Card Count", value: $cardCount, in: 1...6)
            .labelsHidden()
            .padding()
          Spacer()
        }
        .zIndex(1)
        .foregroundColor(preferences.textColor)
        .padding(.top, 40)
        RandomGeneratorView {
          Image(currentCard)
            .scaleEffect(animationAmount)
        }
        .onRandomTouchDown {
          animationAmount = 0.97
        }
        .onRandomTouchUp {
          animationAmount = 1
        }
        .onRandomPressed {
          let value = "23456789TJQK".randomElement()!
          let suit = "CHSD".randomElement()!
          currentCard = String(value).appending(String(suit))
        }
      }
    }
}
