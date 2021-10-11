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
  @Environment(\.managedObjectContext) var moc
  @State private var cardCount = 1.0
  var columns: [GridItem] {
    var gridArray = [GridItem]()
    var count = 3
    if cardCount > 4 {
      (0..<3).forEach{_ in gridArray.append(GridItem(.flexible())) }
      return gridArray
    }
    while gridArray.count == 0 {
      if Int(cardCount)%count == 0 {
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
        preferences.themeColor.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
        VStack {
          VStack {
            Text("Card Count: \(Int(cardCount))")
              .font(.system(.title, design: .rounded))
              .fontWeight(.medium)
              .padding(.top)
            Stepper("", value: $cardCount, in: 1...6)
              .labelsHidden()
              .padding(.horizontal)
              .padding(.bottom)
          }
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 15)
              .fill(Color(uiColor: .secondarySystemGroupedBackground))
          )
          .padding([.horizontal, .top])
          RandomGeneratorView("Card") {
              VStack {
                HStack {
                  ForEach(0..<(currentCards.count <= 3 ? currentCards.count : Int(ceil(Double(currentCards.count)/2))), id: \.self) {
                    Image(currentCards[$0].name)
                      .resizable()
                      .scaledToFit()
                      .aspectRatio(contentMode: .fit)
                      .scaleEffect(animationAmount)
                  }
                }
                if currentCards.count > 3 {
                  HStack {
                    ForEach(Int(ceil(Double(currentCards.count)/2))..<currentCards.count, id: \.self) {
                      Image(currentCards[$0].name)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(animationAmount)
                    }
                  }
                }
              }
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
              .padding(.horizontal, 20)
              .onChange(of: cardCount) { newValue in
                if Int(cardCount) > currentCards.count {
                  currentCards.append(CardImage(name: "RED_BACK"))
                } else if Int(cardCount) < currentCards.count {
                  currentCards.removeLast()
                }
              }
          }
          .randomButtonOverContent(false)
          .onRandomTouchDown {
            animationAmount = 0.97
          }
          .onRandomTouchUp {
            animationAmount = 1
          }
          .onRandomPressed {
            currentCards = (1...Int(cardCount)).map({_ in
              let value = "23456789TJQK".randomElement()!
              let suit = "CHSD".randomElement()!
              let card = String(value).appending(String(suit))
              return CardImage(name: card)
            })
            let coreDataItem = Random(context: moc)
            coreDataItem.randomType = "Card"
            coreDataItem.timestamp = Date()
            coreDataItem.value = (currentCards.map { $0.name }).joined(separator: "\n")
            try? moc.save()
          }
          .generateMultipleTimes({
            return {
              let cards: [String] = (1...Int(cardCount)).map({_ in
                let value = "23456789TJQK".randomElement()!
                let suit = "CHSD".randomElement()!
                let card = String(value).appending(String(suit))
                return card
              })
              return cards.joined(separator: "\n")
            }
          })
          .formatHistoryValue { string in
            let cards = string.split(separator: "\n").map { String($0) }
            return AnyView(cardVStack(cards: cards))
          }
        }
        
      }
    }
}
@ViewBuilder
func cardVStack(cards: [String]) -> some View {
  let specialNum: Int = {
    if cards.count > 4 {
      return 3
    } else if cards.count == 4 {
      return 2
    } else {
      return cards.count
    }
  }()
  VStack {
    ForEach(0..<Int(ceil(Double(cards.count)/Double(specialNum)))) { num in
      cardHStack(cards: cards, range: num*specialNum..<num*specialNum+specialNum)
    }
  }
}
@ViewBuilder
func cardHStack(cards: [String], range: Range<Int>) -> some View {
  HStack {
    if range.lowerBound < cards.count {
      ForEach(range, id: \.self) { card in
        if cards.count <= card {
          Rectangle()
            .fill(.clear)
        } else {
          Image(cards[card])
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
      }
    }
  }
}

private struct CardImage: Identifiable, Hashable {
  let id = UUID()
  let name: String
}
