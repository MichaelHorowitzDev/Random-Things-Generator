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
    didSet { saveUserDefaults(value: types, key: typesDefaults) }
  }
  @Published var typesOn: [String : Bool] {
    didSet { saveUserDefaults(value: typesOn, key: typesOnDefaults) }
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
    types = defaults.stringArray(forKey: typesDefaults) ?? defaultTypes
    typesOn = defaults.dictionary(forKey: typesOnDefaults) as? [String : Bool] ?? defaultTypesOn
  }
  private var themeColorDefaults = "theme_color"
  private var randomButtonDefaults = "shows_random_button"
  private var hapticFeedbackDefaults = "has_haptic_feedback"
  private var generatorPreferencesDefaults = "generator_view_preferences"
  private var typesDefaults = "types_defaults"
  private var typesOnDefaults = "types_on_defaults"
}
