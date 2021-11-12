//
//  UserPreferences.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/7/21.
//

import SwiftUI

//private let defaultTypes = ["Number", "Card", "Dice", "Coin", "Color", "Date", "Map", "Letter", "Lists"]
//private let defaultTypesOn = Dictionary(uniqueKeysWithValues: defaultTypes.map({ type in
//  (type, true)
//}))
private let defaultTypes = [
  ("Number", true),
  ("Card", true),
  ("Dice", true),
  ("Coin", true),
  ("Color", true),
  ("Date", true),
  ("Map", true),
  ("Letter", false),
  ("Password", false),
  ("Lists", true)
]
var defaultTypesOn: [String : Bool] {
  Dictionary(uniqueKeysWithValues: defaultTypes)
}

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
  @Published var hasShakeToGenerate = false {
    didSet { saveUserDefaults(value: hasShakeToGenerate, key: shakeDefaults) }
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
    defaults.set(value, forKey: key)
  }
  init() {
    themeColor = Color.withData(defaults.data(forKey: themeColorDefaults) ?? Color.html.dodgerBlue.data) ?? Color.html.dodgerBlue
    showsRandomButton = defaults.object(forKey: randomButtonDefaults) as? Bool ?? true
    hasHapticFeedback = defaults.object(forKey: hapticFeedbackDefaults) as? Bool ?? true
    var initTypes = defaults.stringArray(forKey: typesDefaults) ?? defaultTypes.map { $0.0 }
    initTypes.append(contentsOf: Set(initTypes).symmetricDifference(Set(defaultTypes.map { $0.0 })))
    var initTypesOn = defaults.dictionary(forKey: typesOnDefaults) as? [String : Bool] ?? defaultTypesOn
    defaultTypes.forEach { tuple in
      initTypesOn[tuple.0] = initTypesOn[tuple.0] ?? tuple.1
    }
    types = initTypes
//    types = defaultTypes.filter { type in initTypesOn.contains(where: { $0.key == type }) }
    typesOn = initTypesOn
    self.onTypes = initTypes.filter({ initTypesOn[$0] == true }).map { OnTypes(type: $0) }
  }
  private var themeColorDefaults = "theme_color"
  private var randomButtonDefaults = "shows_random_button"
  private var hapticFeedbackDefaults = "has_haptic_feedback"
  private var shakeDefaults = "can_shake"
  private var generatorPreferencesDefaults = "generator_view_preferences"
  private var typesDefaults = "types_defaults"
  private var typesOnDefaults = "types_on_defaults"
}
