//
//  CoinFlipper.swift
//  CoinFlipper
//
//  Created by Michael Horowitz on 8/28/21.
//

import SwiftUI

struct CoinFlipper: View {
  @State private var heads = true
  @EnvironmentObject var preferences: UserPreferences
  @State private var fadeOut = false
  @State private var animationAmount: CGFloat = 1
  @Environment(\.managedObjectContext) var moc
    var body: some View {
      RandomGeneratorView("Coin") {
        VStack {
          Text(heads ? "Heads" : "Tails")
            .foregroundColor(preferences.textColor)
            .font(.system(size: 60, weight: .medium, design: .rounded))
            .minimumScaleFactor(0.3)
            .padding(.top, 25)
            .padding(.horizontal, 20)
            .scaleEffect(animationAmount)
          Spacer()
        }
        Image(heads ? Coins.halfDollarObverse : Coins.halfDollarReverse)
          .resizable()
          .scaledToFit()
          .padding(20)
          .scaleEffect(animationAmount)
      }
      .randomButtonTitle("Flip")
//      .onRandomPressed {
//        heads = Bool.random()
//        let coreDataItem = Random(context: moc)
//        coreDataItem.randomType = "Coin"
//        coreDataItem.timestamp = Date()
//        coreDataItem.value = heads ? "Heads" : "Tails"
//        try? moc.save()
//      }
      .onRandomTouchDown {
        animationAmount = 0.97
      }
      .onRandomTouchUp {
        animationAmount = 1
      }
      .generateRandom({
        return {
          Bool.random() ? "Heads" : "Tails"
        }
      })
      .defaultValue("Heads")
      .onRandomSuccess({ result in
        heads = result == "Heads"
        let coreDataItem = Random(context: moc)
        coreDataItem.randomType = "Coin"
        coreDataItem.timestamp = Date()
        coreDataItem.value = heads ? "Heads" : "Tails"
        try? moc.save()
      })
      .formatHistoryValue { string in
        if string == "Heads" {
          return AnyView(Image(Coins.halfDollarObverse)
                          .resizable()
                          .aspectRatio(contentMode: .fit))
        } else if string == "Tails" {
          return AnyView(Image(Coins.halfDollarReverse)
                          .resizable()
                          .aspectRatio(contentMode: .fit))
        } else {
          return AnyView(Text("Unknown"))
        }
      }
    }
}
private struct Coins {
  static var halfDollarObverse = "half_dollar_obverse"
  static var halfDollarReverse = "half_dollar_reverse"
}
