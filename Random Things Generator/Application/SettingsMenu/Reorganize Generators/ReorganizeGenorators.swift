//
//  ReorganizeGenorators.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/24/21.
//

import SwiftUI

struct ReorganizeGenorators: View {
  @EnvironmentObject var preferences: UserPreferences
    var body: some View {
      List {
        ForEach(0..<preferences.types.count, id: \.self) { num in
          HStack {
            Text(preferences.types[num])
            Spacer()
            ReorganizeGeneratorsToggle(typesOn: $preferences.typesOn, type: preferences.types[num])
          }
        }
        .onMove { indexSet, int in
          preferences.types.move(fromOffsets: indexSet, toOffset: int)
        }
      }
      .navigationTitle("Reorganize")
      .environment(\.editMode, Binding.constant(EditMode.active))
    }
}

struct ReorganizeGeneratorsToggle: View {
  @Binding private var typesOn: [String : Bool]
  private var type: String
  @State private var typeBool: Bool
  init(typesOn: Binding<[String : Bool]>, type: String) {
    _typesOn = typesOn
    self.type = type
    let bool = typesOn[type].wrappedValue ?? true
    _typeBool = State(initialValue: bool)
  }
  var body: some View {
    Toggle("", isOn: $typeBool)
      .onChange(of: typeBool) { newValue in
        typesOn[type] = typeBool
      }
  }
}
