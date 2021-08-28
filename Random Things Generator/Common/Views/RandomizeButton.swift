//
//  RandomizeButton.swift
//  RandomizeButton
//
//  Created by Michael Horowitz on 8/26/21.
//

import SwiftUI

struct RandomizeButton: View {
  let buttonTitle: String
  let buttonPressed: () -> ()
  private var onTapDown: (() -> Void)?
  @State private var isPressingDown = false
  @EnvironmentObject var preferences: UserPreferences
  init(_ buttonTitle: String, _ buttonPressed: @escaping () -> ()) {
    self.buttonTitle = buttonTitle
    self.buttonPressed = buttonPressed
  }
  var body: some View {
    Button {
      buttonPressed()
    } label: {
      Text("Randomize")
        .foregroundColor(.black)
        .font(.title)
        .fontWeight(.medium)
        .frame(height: isPressingDown ? 65 : 70)
        .frame(maxWidth: .infinity)
    }
    .background(Color.white)
    .cornerRadius(15)
    .padding()
    .padding([.leading, .trailing, .bottom, .top], isPressingDown ? 2.5 : 0)
    .simultaneousGesture(
      DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({
      print("DOWN \($0)")
        isPressingDown = true
        onTapDown?()
      }).onEnded({
        print("ENDED \($0)")
        isPressingDown = false
        if preferences.hasHapticFeedback {
          UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
      })
    )
  }
}

extension RandomizeButton {
  func onTapDown(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onTapDown = closure
    return copy
  }
}
