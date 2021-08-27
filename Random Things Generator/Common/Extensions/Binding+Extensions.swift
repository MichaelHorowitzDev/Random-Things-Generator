//
//  Binding+Extensions.swift
//  Binding+Extensions
//
//  Created by Michael Horowitz on 8/27/21.
//

import SwiftUI

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
  Binding<Bool>(
    get: { !value.wrappedValue },
    set: { value.wrappedValue = !$0 }
  )
}
