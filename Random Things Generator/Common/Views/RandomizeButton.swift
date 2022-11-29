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
  private var onTouchDown: (() -> Void)?
  private var onTouchUp: (() -> Void)?
  private var isDisabled = false
  @GestureState private var isPressingDown = false
  @EnvironmentObject var preferences: UserPreferences
  init(_ buttonTitle: String, _ buttonPressed: @escaping () -> ()) {
    self.buttonTitle = buttonTitle
    self.buttonPressed = buttonPressed
  }
  var body: some View {
    Group {
      if isDisabled {
        Button {

        } label: {
          Text(buttonTitle)
            .foregroundColor(.black)
            .font(.title)
            .fontWeight(.medium)
            .frame(height: isPressingDown ? 65 : 70)
            .frame(maxWidth: .infinity)
        }
        .background(.gray)
        .disabled(true)
      } else {
        Button {
          buttonPressed()
          if preferences.hasHapticFeedback {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
          }
        } label: {
          Text(buttonTitle)
            .foregroundColor(.black)
            .font(.title)
            .fontWeight(.medium)
            .frame(height: isPressingDown ? 65 : 70)
            .frame(maxWidth: .infinity)
        }
        .background(.white)
        .simultaneousGesture(
          DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($isPressingDown, body: { value, state, transaction in
              state = true
            })
        )
        .onChange(of: isPressingDown) { newValue in
          newValue ? onTouchDown?() : onTouchUp?()
        }
      }
    }
    .cornerRadius(15)
    .padding()
    .padding([.leading, .trailing, .bottom, .top], isPressingDown ? 2.5 : 0)
  }
}

extension RandomizeButton {
  func onTouchDown(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onTouchDown = closure
    return copy
  }
  func onTouchUp(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onTouchUp = closure
    return copy
  }
  func isDisabled(_ bool: Bool) -> Self {
    var copy = self
    copy.isDisabled = bool
    return copy
  }
}
