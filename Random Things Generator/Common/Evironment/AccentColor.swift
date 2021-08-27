//
//  AccentColor.swift
//  AccentColor
//
//  Created by Michael Horowitz on 8/26/21.
//

import SwiftUI

struct AccentColorKey: EnvironmentKey {
  static let defaultValue = Color.blue
}

extension EnvironmentValues {
  var accentColor: Color {
    get { self[AccentColorKey.self] }
    set { self[AccentColorKey.self] = newValue }
  }
}

extension View {
  func accentColor(_ color: Color) -> some View {
    environment(\.accentColor, color)
  }
}
