//
//  NumberGenerator.swift
//  NumberGenerator
//
//  Created by Michael Horowitz on 8/26/21.
//

import SwiftUI

struct NumberGenerator: View {
  @State private var firstNumber = ""
  @State private var secondNumber = ""
  @FocusState private var isFocused: Bool
  @Environment(\.accentColor) var accentColor
    var body: some View {
      ZStack {
        Color.blue.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
        VStack {
          HStack(spacing: 20) {
            NumberEntry(placeholder: "First Number", string: $firstNumber, isFocused: $isFocused)
            NumberEntry(placeholder: "Second Number", string: $secondNumber, isFocused: $isFocused)
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
          .foregroundColor(accentColor.isLight ? .black : .white)
        .navigationTitle("Number")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
}

private struct NumberEntry: View {
  let placeholder: String
  @Binding var string: String
  private var isFocused: FocusState<Bool>.Binding
  init(placeholder: String, string: Binding<String>, isFocused: FocusState<Bool>.Binding) {
    self.placeholder = placeholder
    self._string = string
    self.isFocused = isFocused
  }
  var body: some View {
    TextField(placeholder, text: $string)
      .textFieldStyle(.roundedBorder)
      .keyboardType(.numberPad)
      .focused(isFocused)
  }
}

struct NumberGenerator_Previews: PreviewProvider {
    static var previews: some View {
        NumberGenerator()
    }
}
