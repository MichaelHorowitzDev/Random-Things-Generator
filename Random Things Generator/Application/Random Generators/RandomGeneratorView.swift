//
//  RandomGeneratorView.swift
//  RandomGeneratorView
//
//  Created by Michael Horowitz on 8/28/21.
//

import SwiftUI

public struct RandomGeneratorView<Content>: View where Content: View {
  @EnvironmentObject var preferences: UserPreferences
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  private var randomButtonTitle = "Randomize"
  private var onRandomPressed: (() -> Void)?
  private var onTap: (() -> Void)?
  private var onTapDown: (() -> Void)?
  private var canTap = true
  private func generateHaptic() {
    if preferences.hasHapticFeedback {
      UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
  }
  public var body: some View {
      ZStack {
        preferences.themeColor.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
        if preferences.showsRandomButton {
          VStack {
            Spacer()
            RandomizeButton("Randomize") {
              onRandomPressed?()
              generateHaptic()
            }
            .onTapDown {
              onTapDown?()
            }
          }
        }
        content
      }
      .navigationBarTitleDisplayMode(.inline)
      .onTapGesture {
        onTap?()
        if canTap {
          if !preferences.showsRandomButton {
            onRandomPressed?()
            generateHaptic()
          }
        }
      }
//      .simultaneousGesture(
//        DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({_ in
//          print("DOWN")
//          if canTap {
//            if !preferences.showsRandomButton {
//              onTapDown?()
//            }
//          }
//        })
//      )
    }
}
extension RandomGeneratorView {
  func randomButtonTitle(_ title: String) -> Self {
    var copy = self
    copy.randomButtonTitle = title
    return copy
  }
  func onRandomPressed(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onRandomPressed = closure
    return copy
  }
  func onTap(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onTap = closure
    return copy
  }
  func canTapToRandomize(_ bool: Bool) -> Self {
    var copy = self
    copy.canTap = bool
    return copy
  }
  func onRandomTapDown(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onTapDown = closure
    return copy
  }
}

//struct RandomGeneratorView_Previews: PreviewProvider {
//    static var previews: some View {
//        RandomGeneratorView()
//    }
//}
