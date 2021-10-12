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
  let viewContext = PersistenceController.shared.container.viewContext
  
  init(uuid: UUID) {
    let request = NSFetchRequest<GeneratorPreferences>(entityName: "GeneratorPreferences")
    request.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
    request.fetchLimit = 1
    let fetched = try? viewContext.fetch(request)
    if let generatorPreference = fetched?.first {
      self.preferences = generatorPreference
    } else {
      let generatorPreference = GeneratorPreferences(context: viewContext)
      self.preferences = generatorPreference
      try? viewContext.save()
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
      let generatorPreference = GeneratorPreferences(context: viewContext)
      self.preferences = generatorPreference
      try? viewContext.save()
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
//  @EnvironmentObject var preferences: UserPreferences
//  @State private var dontRepeatToggle = false
  private func generateHaptic() {
    if preferences.hasHapticFeedback {
      UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
  }
//  var generatorPreferences: GeneratorPreferences {
//    if let uuid = uuid {
//      return preferences.generatorViewPreferences.first(where: { $0.uuid == uuid }) ?? GeneratorPreferences(uuid: uuid)
//    } else {
//      return preferences.generatorViewPreferences.first(where: { $0.randomType == randomType }) ?? GeneratorPreferences(randomType: randomType)
//    }
//  }
  public var body: some View {
      ZStack {
        preferences.themeColor.ignoresSafeArea(.all, edges: [.horizontal, .bottom])
          .zIndex(-1)
            if buttonOverContent {
              if preferences.showsRandomButton || overrideShowRandomButton {
                VStack {
                  Spacer()
                  RandomizeButton(randomButtonTitle) {
                    onRandomPressed?()
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
              }
              content
            } else {
              if preferences.showsRandomButton || overrideShowRandomButton {
                VStack {
                  Spacer()
                  content
                  RandomizeButton(randomButtonTitle) {
                    onRandomPressed?()
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
              } else {
                content
                  .padding(.bottom)
              }
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
                if generateMultipleTimes != nil {
                  NavigationLink {
                    GenerateMultipleTimes(generateMultipleTimes!, formatValue: formatHistoryValue)
                  } label: {
                    Text("Generate Multiple Times")
                  }
                }
                Section {
//                  Toggle(isOn: $generatorSettings.preferences.dontRepeat) {
//                    Text("Don't Repeat")
//                  }
//                  .onChange(of: generatorSettings.preferences.dontRepeat) { newValue in
////                    preferences.generatorViewPreferences.append(generatorSettings.preferences)
//                  }
                } header: {
                  Text("Preferences")
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
  func generateMultipleTimes(_ function: () -> (() -> String)?) -> Self {
    if function() == nil {
      return self
    } else {
      var copy = self
      copy.generateMultipleTimes = function()
      return copy
    }
  }
  func customHistoryPredicate(_ predicate: NSPredicate) -> Self {
    var copy = self
    copy.customHistoryPredicate = predicate
    return copy
  }
}
