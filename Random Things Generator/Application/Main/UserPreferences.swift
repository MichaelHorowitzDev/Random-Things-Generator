//
//  UserPreferences.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/7/21.
//

import SwiftUI

private let defaultTypes = ["Number", "Card", "Dice", "Coin", "Color", "Date", "Map", "Lists"]
private let defaultTypesOn = Dictionary(uniqueKeysWithValues: defaultTypes.map({ type in
  (type, true)
}))

class UserPreferences: ObservableObject {
  @Published var themeColor: Color = .html.dodgerBlue {
    didSet { saveUserDefaults(value: themeColor.data, key: themeColorDefaults) }
  }
  @Published var showsRandomButton = true {
    didSet { saveUserDefaults(value: showsRandomButton, key: randomButtonDefaults) }
  }
  @Published var hasHapticFeedback = true {
    didSet { saveUserDefaults(value: hasHapticFeedback, key: hapticFeedbackDefaults) }
  }
  @Published var types: [String] {
    didSet { updateOnTypes(); saveUserDefaults(value: types, key: typesDefaults) }
  }
  @Published var typesOn: [String : Bool] {
    didSet { updateOnTypes(); saveUserDefaults(value: typesOn, key: typesOnDefaults) }
  }
  @Published var onTypes: [OnTypes]
  struct OnTypes: Identifiable {
    var id = UUID()
    let type: String
  }
  func updateOnTypes() {
    onTypes = types.filter({ typesOn[$0] == true }).map { OnTypes(type: $0) }
  }
  let defaults = UserDefaults.standard
  var textColor: Color {
    themeColor.isLight ? .black : .white
  }
  func saveUserDefaults(value: Any, key: String) {
    print(value, key)
    defaults.set(value, forKey: key)
  }
  init() {
    themeColor = Color.withData(defaults.data(forKey: themeColorDefaults) ?? Color.html.dodgerBlue.data) ?? Color.html.dodgerBlue
    showsRandomButton = defaults.object(forKey: randomButtonDefaults) as? Bool ?? true
    hasHapticFeedback = defaults.object(forKey: hapticFeedbackDefaults) as? Bool ?? true
    let initTypes = defaults.stringArray(forKey: typesDefaults) ?? defaultTypes
    let initTypesOn = defaults.dictionary(forKey: typesOnDefaults) as? [String : Bool] ?? defaultTypesOn
    types = initTypes
    typesOn = initTypesOn
    self.onTypes = initTypes.filter({ initTypesOn[$0] == true }).map { OnTypes(type: $0) }
  }
  private var themeColorDefaults = "theme_color"
  private var randomButtonDefaults = "shows_random_button"
  private var hapticFeedbackDefaults = "has_haptic_feedback"
  private var generatorPreferencesDefaults = "generator_view_preferences"
  private var typesDefaults = "types_defaults"
  private var typesOnDefaults = "types_on_defaults"
}
