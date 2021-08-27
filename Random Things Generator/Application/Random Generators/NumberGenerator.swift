//
//  NumberGenerator.swift
//  NumberGenerator
//
//  Created by Michael Horowitz on 8/26/21.
//

import SwiftUI
import Combine

struct NumberGenerator: View {
  @State private var firstNumber = "" {
    didSet {
      print(firstNumber)
    }
  }
  @State private var secondNumber = ""
  @FocusState private var isFocused: Bool
  @EnvironmentObject var preferences: UserPreferences
    var body: some View {
      ZStack {
        preferences.themeColor.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
        VStack {
          HStack(spacing: 20) {
            NumberEntry(placeholder: "First Number", number: $firstNumber, isFocused: $isFocused)
            NumberEntry(placeholder: "Second Number", number: $secondNumber, isFocused: $isFocused)
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
        VStack {
          Spacer()
          RandomizeButton(buttonTitle: "Randomize") {
            print("pressed")
          }
        }
        Text("?")
          .font(.system(size: 100))
          .foregroundColor(preferences.themeColor.isLight ? .black : .white)
        .navigationTitle("Number")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
}

private struct NumberEntry: View {
  let placeholder: String
  @Binding var number: String {
    willSet {
      print(number)
      print(newValue)
    }
  }
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
