//
//  ReorganizeGenorators.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/24/21.
//

import SwiftUI

struct ReorganizeGenerators: View {
  @EnvironmentObject var preferences: UserPreferences
    var body: some View {
      List {
        ForEach(preferences.types, id: \.self) { string in
          HStack {
            Text(string)
            Spacer()
            ReorganizeGeneratorsToggle(typesOn: preferences.typesOn, type: string)
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
  @EnvironmentObject var preferences: UserPreferences
  private var type: String
  @State private var typeBool: Bool
  init(typesOn: [String : Bool], type: String) {
    self.type = type
    let bool = typesOn[type] ?? true
    _typeBool = State(initialValue: bool)
  }
  var body: some View {
    Toggle("", isOn: $typeBool)
      .onChange(of: typeBool) { newValue in
        preferences.typesOn[type] = typeBool
      }
  }
}
