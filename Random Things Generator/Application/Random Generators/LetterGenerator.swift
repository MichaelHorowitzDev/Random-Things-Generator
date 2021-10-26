//
//  LetterGenerator.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/26/21.
//

import SwiftUI

struct LetterGenerator: View {
  @State private var letter = "?"
  @State private var animationAmount: CGFloat = 1
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.managedObjectContext) var moc
  var body: some View {
    RandomGeneratorView("Letter") {
      Text(letter)
        .font(.system(size: 100))
        .minimumScaleFactor(0.2)
        .lineLimit(1)
        .foregroundColor(preferences.textColor)
        .padding()
        .scaleEffect(animationAmount)
    }
    .onRandomTouchDown {
      animationAmount = 0.97
    }
    .onRandomTouchUp {
      animationAmount = 1
    }
    .generateRandom {
      return {
        String("ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()!)
      }
    }
    .onRandomSuccess { result in
      letter = result
      let random = Random(context: moc)
      random.value = result
      random.timestamp = Date()
      random.randomType = "Letter"
      try? moc.save()
    }
  }
}
