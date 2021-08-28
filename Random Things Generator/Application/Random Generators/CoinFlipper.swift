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
    var body: some View {
      RandomGeneratorView {
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
      .onRandomPressed {
        heads = Bool.random()
      }
      .onRandomTouchDown {
        animationAmount = 0.97
      }
      .onRandomTouchUp {
        animationAmount = 1
      }
      .navigationTitle("Coin")
    }
}
private struct Coins {
  static var halfDollarObverse = "half_dollar_obverse"
  static var halfDollarReverse = "half_dollar_reverse"
}

struct CoinFlipper_Previews: PreviewProvider {
    static var previews: some View {
        CoinFlipper()
    }
}
