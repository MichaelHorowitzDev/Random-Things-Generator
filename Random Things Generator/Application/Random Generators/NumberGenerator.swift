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
  @FocusState private var isFocused: Bool
  @EnvironmentObject var preferences: UserPreferences
    var body: some View {
      RandomGeneratorView {
        VStack {
          HStack(spacing: 20) {
            NumberEntry(placeholder: "First Number", number: $firstNumber, isFocused: $isFocused)
              .highPriorityGesture(TapGesture().onEnded({
              }))
            NumberEntry(placeholder: "Second Number", number: $secondNumber, isFocused: $isFocused)
              .highPriorityGesture(TapGesture().onEnded({
              }))
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
          .foregroundColor(preferences.themeColor.isLight ? .black : .white)
          .padding()
        .navigationTitle("Number")
        .navigationBarTitleDisplayMode(.inline)
      }
      .onRandomPressed {
        isFocused = false
        setNumbers()
        guard let num1 = Int(firstNumber) else { return }
        guard let num2 = Int(secondNumber) else { return }
        let randNum = Int.random(in: num1...num2)
        randomNumber = String(randNum)
      }
      .onTap {
        isFocused = false
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

struct NumberGenerator_Previews: PreviewProvider {
    static var previews: some View {
        NumberGenerator()
    }
}
