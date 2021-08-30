//
//  CardRandomizer.swift
//  CardRandomizer
//
//  Created by Michael Horowitz on 8/28/21.
//

import SwiftUI

struct CardRandomizer: View {
  @State private var currentCards = [CardImage(name: "RED_BACK")]
  @State private var animationAmount: CGFloat = 1
  @EnvironmentObject var preferences: UserPreferences
  @State private var cardCount = 1
  var columns: [GridItem] {
    var gridArray = [GridItem]()
    var count = 3
    if cardCount > 4 {
      (0..<3).forEach{_ in gridArray.append(GridItem(.flexible())) }
      return gridArray
    }
    while gridArray.count == 0 {
      if cardCount%count == 0 {
        (0..<count).forEach{_ in gridArray.append(GridItem(.flexible())) }
        break
      }
      count -= 1
      if count == 0 {
        break
      }
    }
    return gridArray
  }
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
          LazyVGrid(columns: columns) {
            ForEach(currentCards, id: \.self) {
              Image($0.name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(animationAmount)
            }
          }
          .padding(.horizontal, 40)
          .onChange(of: cardCount) { newValue in
            if cardCount > currentCards.count {
              currentCards.append(CardImage(name: "RED_BACK"))
            } else if cardCount < currentCards.count {
              currentCards.removeLast()
            }
          }
        }
        .onRandomTouchDown {
          animationAmount = 0.97
        }
        .onRandomTouchUp {
          animationAmount = 1
        }
        .onRandomPressed {
          currentCards = (1...cardCount).map({_ in
            let value = "23456789TJQK".randomElement()!
            let suit = "CHSD".randomElement()!
            let card = String(value).appending(String(suit))
            return CardImage(name: card)
          })
        }
      }
    }
}

private struct CardImage: Identifiable, Hashable {
  let id = UUID()
  let name: String
}
