//
//  NumberGenerator.swift
//  NumberGenerator
//
//  Created by Michael Horowitz on 8/26/21.
//

import SwiftUI
import Combine

struct NumberGenerator: View {
  @State private var firstNumber = ""
  @State private var secondNumber = ""
  @State private var randomNumber = "?"
  @State private var animationAmount: CGFloat = 1
  @FocusState private var isFocused: Bool
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.managedObjectContext) var moc
  @State private var settingsPresented = false
    var body: some View {
      RandomGeneratorView("Number") {
        VStack {
          HStack(spacing: 20) {
            NumberEntry(placeholder: "First Number", number: $firstNumber, isFocused: $isFocused)
              .highPriorityGesture(TapGesture())
            NumberEntry(placeholder: "Second Number", number: $secondNumber, isFocused: $isFocused)
              .highPriorityGesture(TapGesture())
          }
          .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
              Spacer()
              Button("Done") {
                isFocused = false
              }
            }
          }
          .padding()
          .padding(.top, 50)
          Spacer()
        }
        Text(randomNumber)
          .font(.system(size: 100))
          .minimumScaleFactor(0.2)
          .lineLimit(1)
          .foregroundColor(preferences.textColor)
          .padding()
          .scaleEffect(animationAmount)
      }
      .onRandomPressed {
        isFocused = false
        setNumbers()
//        guard let num1 = Int(firstNumber) else { return }
//        guard let num2 = Int(secondNumber) else { return }
//        let randNum = Int.random(in: num1...num2)
//        randomNumber = String(randNum)
//        let coreDataItem = Random(context: moc)
//        coreDataItem.randomType = "Number"
//        coreDataItem.timestamp = Date()
//        coreDataItem.value = randomNumber
//        try? moc.save()
      }
      .generateRandom({
        guard let num1 = Int(firstNumber) else { return nil }
        guard let num2 = Int(secondNumber) else { return nil }
        if num1 > num2 { return nil }
        return {
          let randNum = Int.random(in: num1...num2)
          return randNum.description
        }
      })
      .onRandomSuccess({ result in
        randomNumber = result
        let coreDataItem = Random(context: moc)
        coreDataItem.randomType = "Number"
        coreDataItem.timestamp = Date()
        coreDataItem.value = randomNumber
        try? moc.save()
      })
//      .generateMultipleTimes({
//        guard let num1 = Int(firstNumber) else { return nil }
//        guard let num2 = Int(secondNumber) else { return nil }
//        if num1 > num2 { return nil }
//        return {
//          let randNum = Int.random(in: num1...num2)
//          return randNum.description
//        }
//      })
      .onTap {
        isFocused = false
      }
      .onRandomTouchDown {
        animationAmount = 0.97
      }
      .onRandomTouchUp {
        animationAmount = 1
      }
      .canTapToRandomize(!isFocused)
    }
  func setNumbers() {
    guard var num1 = Int(firstNumber) else { return }
    guard var num2 = Int(secondNumber) else { return }
    if num1 >= num2 {
      if String(num2+1).count > 10 {
        num1 = num2 - 1
        firstNumber = String(num1)
      } else {
        num2 = num1 + 1
        secondNumber = String(num2)
      }
    }
  }
}

private struct NumberEntry: View {
  let placeholder: String
  @Binding var number: String
  private var isFocused: FocusState<Bool>.Binding
  init(placeholder: String, number: Binding<String>, isFocused: FocusState<Bool>.Binding) {
    self.placeholder = placeholder
    self._number = number
    self.isFocused = isFocused
  }
  var body: some View {
    TextField(placeholder, text: $number)
      .textFieldStyle(.roundedBorder)
      .keyboardType(.numberPad)
      .focused(isFocused)
      .onReceive(Just(number)) { newValue in
        var filtered = newValue.filter {"0123456789".contains($0)}
        if filtered.count > 10 {
          filtered = String(filtered.prefix(10))
        }
        number = filtered
      }
  }
}
