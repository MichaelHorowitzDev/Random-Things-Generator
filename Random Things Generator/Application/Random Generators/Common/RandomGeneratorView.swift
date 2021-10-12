//
//  RandomGeneratorView.swift
//  RandomGeneratorView
//
//  Created by Michael Horowitz on 8/28/21.
//

import SwiftUI
import CoreData

class RandomGeneratorViewSettings: ObservableObject {
  @Published var preferences: GeneratorPreferences {
    didSet { try? viewContext.save() }
  }
  @Published private(set) var preferencesError: Bool = false
  let viewContext = PersistenceController.shared.container.viewContext
  
  init(uuid: UUID) {
    let request = NSFetchRequest<GeneratorPreferences>(entityName: "GeneratorPreferences")
    request.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
    request.fetchLimit = 1
    let fetched = try? viewContext.fetch(request)
    if let generatorPreference = fetched?.first {
      self.preferences = generatorPreference
    } else {
      if let generatorPreferences = try? GeneratorPreferences.initialize(context: viewContext, uuid: uuid) {
        self.preferences = generatorPreferences
      } else {
        self.preferences = GeneratorPreferences()
        preferencesError = true
      }
    }
  }
  init(randomType: String) {
    let request = NSFetchRequest<GeneratorPreferences>(entityName: "GeneratorPreferences")
    request.predicate = NSPredicate(format: "randomType == %@", randomType as CVarArg)
    request.fetchLimit = 1
    
    let fetched = try? viewContext.fetch(request)
    if let generatorPreference = fetched?.first {
      self.preferences = generatorPreference
    } else {
      if let generatorPreferences = try? GeneratorPreferences.initialize(context: viewContext, randomType: randomType) {
        self.preferences = generatorPreferences
      } else {
        self.preferences = GeneratorPreferences()
        preferencesError = true
      }
    }
  }
}

public struct RandomGeneratorView<Content: View>: View {
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.managedObjectContext) var moc
  @StateObject private var generatorSettings: RandomGeneratorViewSettings
  let content: Content
  
  init(_ randomType: String, isCustomList: Bool = false, uuid: UUID? = nil, @ViewBuilder content: () -> Content) {
    self.content = content()
    self.randomType = randomType
    self.uuid = uuid
    self.isCustomList = isCustomList
    if let uuid = uuid {
      _generatorSettings = StateObject(wrappedValue: RandomGeneratorViewSettings(uuid: uuid))
    } else {
      _generatorSettings = StateObject(wrappedValue: RandomGeneratorViewSettings(randomType: randomType))
    }
  }
  private var randomButtonTitle = "Randomize"
  private var isCustomList = false
  private var uuid: UUID?
  private var onRandomPressed: (() -> Void)?
  private var onRandomSuccess: ((String) -> Void)?
  private var generateRandom: (() -> String)?
  private var onTap: (() -> Void)?
  private var onTouchDown: (() -> Void)?
  private var onTouchUp: (() -> Void)?
  private var canTap = true
  private var gestureDisabled = false
  private var overrideShowRandomButton = false
  @State private var settingsPresented = false
  private var canPresentSettings = true
  var randomType: String
  private var onSettingsPressed: (() -> Void)?
  private var formatHistoryValue: ((String) -> AnyView)?
  private var buttonOverContent = true
  private var settingsContent: AnyView?
  private var generateMultipleTimes: (() -> String)?
  private var customHistoryPredicate: NSPredicate?
  @State private var randomizedValue = ""
  private func generateHaptic() {
    if preferences.hasHapticFeedback {
      UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
  }
  public var body: some View {
      ZStack {
        preferences.themeColor.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
          .zIndex(-1)
        if preferences.showsRandomButton || overrideShowRandomButton {
          VStack {
            Spacer()
            if !buttonOverContent {
              content
            }
            RandomizeButton(randomButtonTitle) {
              onRandomPressed?()
              if let generateRandom = generateRandom {
                var randomValue = generateRandom()
                if generatorSettings.preferences.dontRepeat {
                  while randomValue == randomizedValue {
                    randomValue = generateRandom()
                  }
                }
                randomizedValue = randomValue
                onRandomSuccess?(randomValue)
              }
              generateHaptic()
            }
            .onTouchDown {
              onTouchDown?()
            }
            .onTouchUp {
              onTouchUp?()
            }
          }
          .zIndex(2)
        } else if !buttonOverContent {
          content
            .padding(.bottom)
        }
        if buttonOverContent {
          content
        }
      }
      .navigationTitle(randomType)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            if onSettingsPressed != nil {
              onSettingsPressed?()
            } else {
              if canPresentSettings {
                settingsPresented = true
              }
            }
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(preferences.themeColor)
          }
          .sheet(isPresented: $settingsPresented) {
            RandomHistory(randomType: randomType, customPredicate: customHistoryPredicate, isCustomList: isCustomList, formatValue: formatHistoryValue)
              .settings {
                settingsContent
                if let generateRandom = generateRandom {
                  NavigationLink {
                    GenerateMultipleTimes(generateRandom, formatValue: formatHistoryValue)
                  } label: {
                    Text("Generate Multiple Times")
                  }
                }
                if !generatorSettings.preferencesError {
                  Section {
                    Toggle(isOn: $generatorSettings.preferences.dontRepeat) {
                      Text("Don't Repeat")
                    }
                  } header: {
                    Text("Preferences")
                  }
                }
              }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .gesture(gestureDisabled ? nil : DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({_ in
        if canTap {
          if !preferences.showsRandomButton {
            onTouchDown?()
          }
        }
      }).onEnded({_ in
        if canTap {
          if !preferences.showsRandomButton {
            onTouchUp?()
          }
        }
      }).sequenced(before: TapGesture().onEnded({_ in
        onTap?()
        if canTap {
          if !preferences.showsRandomButton {
            onRandomPressed?()
            generateHaptic()
          }
        }
      })))
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
  ///When the user touches down on the screen. Should be used for animation effects
  func onRandomTouchDown(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onTouchDown = closure
    return copy
  }
  ///When the user touches up from the screen. Doesn't necessarily constitute a tap.
  func onRandomTouchUp(_ closure: @escaping () -> Void) -> Self {
    var copy = self
    copy.onTouchUp = closure
    return copy
  }
  func showRandomButton(_ shows: Bool) -> Self {
    var copy = self
    copy.overrideShowRandomButton = shows
    return copy
  }
  ///Name of Random View used for getting history in Core Data
  func randomType(_ type: String) -> Self {
    var copy = self
    copy.randomType = type
    return copy
  }
  func onSettingsPressed(_ pressed: @escaping () -> Void) -> Self {
    var copy = self
    copy.onSettingsPressed = pressed
    return copy
  }
  func presentsSettings(_ presents: Bool) -> Self {
    var copy = self
    copy.canPresentSettings = presents
    return copy
  }
  func disablesGestures(_ disabled: Bool) -> Self {
    var copy = self
    copy.gestureDisabled = disabled
    return copy
  }
  func formatHistoryValue(@ViewBuilder _ format: @escaping (String) -> AnyView) -> Self {
    var copy = self
    copy.formatHistoryValue = format
    return copy
  }
  func randomButtonOverContent(_ bool: Bool) -> Self {
    var copy = self
    copy.buttonOverContent = bool
    return copy
  }
  func settingsPresentedContent<Content: View>(@ViewBuilder _ settings: () -> Content) -> Self {
    var copy = self
    copy.settingsContent = AnyView(settings())
    return copy
  }
//  func generateMultipleTimes(_ function: () -> (() -> String)?) -> Self {
//    if function() == nil {
//      return self
//    } else {
//      var copy = self
//      copy.generateMultipleTimes = function()
//      return copy
//    }
//  }
  func customHistoryPredicate(_ predicate: NSPredicate) -> Self {
    var copy = self
    copy.customHistoryPredicate = predicate
    return copy
  }
  func onRandomSuccess(_ onSuccess: @escaping (String) -> Void) -> Self {
    var copy = self
    copy.onRandomSuccess = onSuccess
    return copy
  }
  func generateRandom(_ generate: @escaping () -> (() -> String)?) -> Self {
    if generate() == nil {
      return self
    } else {
      var copy = self
      if !isCustomList {
        copy.generateRandom = generate()
      }
      return copy
    }
  }
  func defaultValue(_ value: String) -> Self {
    var copy = self
    copy._randomizedValue = State(wrappedValue: value)
    return copy
  }
}
