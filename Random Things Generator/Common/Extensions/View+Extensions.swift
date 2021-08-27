//
//  View+Extensions.swift
//  View+Extensions
//
//  Created by Michael Horowitz on 8/27/21.
//

import SwiftUI

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
