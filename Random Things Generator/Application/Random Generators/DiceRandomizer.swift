//
//  DiceRandomizer.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/20/21.
//

import SwiftUI

struct DiceRandomizer: View {
  @State private var diceCount = 1
  @State private var currentDice = [DiceItem(number: nil)]
  @State private var animationAmount: CGFloat = 1
  @EnvironmentObject private var preferences: UserPreferences
  @Environment(\.managedObjectContext) var moc
    var body: some View {
      ZStack {
        preferences.themeColor.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
        VStack {
          VStack {
            Text("Dice Count: \(Int(diceCount))")
              .font(.system(.title, design: .rounded))
              .fontWeight(.medium)
              .padding(.top)
            Stepper("", value: $diceCount, in: 1...6)
              .labelsHidden()
              .padding(.horizontal)
              .padding(.bottom)
              .onChange(of: diceCount) {_ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)
              }
          }
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 15)
              .fill(Color(uiColor: .secondarySystemGroupedBackground))
          )
          .padding([.horizontal, .top])
          RandomGeneratorView("Dice") {
            VStack {
              HStack {
                ForEach(0..<(currentDice.count <= 3 ? currentDice.count : Int(ceil(Double(currentDice.count)/2))), id: \.self) {
                  DiceImage(diceName: currentDice[$0].numberImage)
                    .scaleEffect(animationAmount)
                }
              }
              if currentDice.count > 3 {
                HStack {
                  ForEach(Int(ceil(Double(currentDice.count)/2))..<currentDice.count, id: \.self) {
                    DiceImage(diceName: currentDice[$0].numberImage)
                      .scaleEffect(animationAmount)
                  }
                }
              }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding(.horizontal, 20)
            .onChange(of: diceCount) { newValue in
              if diceCount > currentDice.count {
                currentDice.append(DiceItem(number: nil))
              } else if diceCount < currentDice.count {
                currentDice.removeLast()
              }
            }
          }
          .randomButtonTitle("Roll")
          .randomButtonOverContent(false)
          .onRandomTouchDown {
            animationAmount = 0.97
          }
          .onRandomTouchUp {
            animationAmount = 1
          }
          .generateRandom {
            return {
              let dice: [String] = (0..<diceCount).map {_ in
                (1...6).randomElement()!.description
              }
              return dice.joined(separator: "\n")
            }
          }
          .onRandomSuccess { result in
            currentDice = result.split(separator: "\n").map({ element in
              return DiceItem(number: Int(element))
            })
            let coreDataItem = Random(context: moc)
            coreDataItem.timestamp = Date()
            coreDataItem.randomType = "Dice"
            coreDataItem.value = (currentDice.map { $0.number }.compactMap { $0?.description }).joined(separator: "\n")
            try? moc.save()
          }
          .formatHistoryValue { string in
            let formatDice = string.split(separator: "\n").map { element in
              DiceItem(number: Int(element))
            }
            return AnyView(
              VStack {
                HStack {
                  ForEach(0..<(formatDice.count <= 3 ? formatDice.count : Int(ceil(Double(formatDice.count)/2))), id: \.self) {
                    DiceImage(diceName: formatDice[$0].numberImage)
                  }
                }
                if formatDice.count > 3 {
                  HStack {
                    ForEach(Int(ceil(Double(formatDice.count)/2))..<formatDice.count, id: \.self) {
                      DiceImage(diceName: formatDice[$0].numberImage)
                    }
                  }
                }
              }
            )
          }
        }
      }
    }
}

private struct DiceImage: View {
  let diceName: String
  var body: some View {
    Image(diceName)
      .resizable()
      .scaledToFit()
      .aspectRatio(contentMode: .fit)
  }
}

private struct DiceItem: Identifiable, Hashable {
  let id = UUID()
  let number: Int?
  
  var numberImage: String {
    switch number {
    case 1:
      return "dice 1"
    case 2:
      return "dice 2"
    case 3:
      return "dice 3"
    case 4:
      return "dice 4"
    case 5:
      return "dice 5"
    case 6:
      return "dice 6"
    default:
      return "dice question"
    }
  }
}
