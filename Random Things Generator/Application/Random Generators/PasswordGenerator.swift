//
//  PasswordGenerator.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 11/11/21.
//

import SwiftUI

struct PasswordGenerator: View {
  @State private var generatedPassword = "?"
  @State private var length: Double = 5
  @State private var includesNumbers = true
  @State private var lowercaseLetters = true
  @State private var uppercaseLetters = true
  @State private var includesSymbols = true
  @Environment(\.managedObjectContext) var moc
  @EnvironmentObject var preferences: UserPreferences
  @State private var animationAmount: CGFloat = 1
    var body: some View {
      ZStack {
        preferences.themeColor.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
        VStack {
          VStack {
            HStack {
              Text("Password Length")
              Spacer()
              VStack(spacing: 0) {
                Text(String(Int(length)))
                Slider(value: $length, in: 5...35, step: 1)
              }
            }
            Toggle("Includes Numbers", isOn: $includesNumbers)
            Toggle("Includes Lowercase Letters", isOn: $lowercaseLetters)
            Toggle("Includes Uppercase Letters", isOn: $lowercaseLetters)
            Toggle("Includes Symbols", isOn: $includesSymbols)
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 15)
              .fill(Color(uiColor: .secondarySystemGroupedBackground))
          )
          .padding([.horizontal, .top])
          RandomGeneratorView("Password") {
            Text(generatedPassword)
              .font(.system(size: 100))
              .minimumScaleFactor(0.05)
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
            if !includesNumbers && !lowercaseLetters && !uppercaseLetters && !includesSymbols {
              return nil
            }
            return {
              var characters = [Character]()
              let numbers = String.numbers
              let lowercase = String.lowercaseLetters
              let uppercase = String.uppercaseLetters
              let symbols = String.symbols
              if includesNumbers {
                characters.append(numbers.randomElement()!)
              }
              if lowercaseLetters {
                characters.append(lowercase.randomElement()!)
              }
              if uppercaseLetters {
                characters.append(uppercase.randomElement()!)
              }
              if includesSymbols {
                characters.append(symbols.randomElement()!)
              }
              while characters.count < Int(length) {
                var chars = [Character]()
                if includesNumbers {
                  chars.append(numbers.randomElement()!)
                }
                if lowercaseLetters {
                  chars.append(lowercase.randomElement()!)
                }
                if uppercaseLetters {
                  chars.append(uppercase.randomElement()!)
                }
                if includesSymbols {
                  chars.append(symbols.randomElement()!)
                }
                characters.append(chars.randomElement()!)
              }
              characters.shuffle()
              return String(characters.prefix(Int(length)))
            }
          }
          .onRandomSuccess { result in
            self.generatedPassword = result
            let coreDataItem = Random(context: moc)
            coreDataItem.randomType = "Password"
            coreDataItem.timestamp = Date()
            coreDataItem.value = result
            try? moc.save()
          }
        }
      }
    }
}
