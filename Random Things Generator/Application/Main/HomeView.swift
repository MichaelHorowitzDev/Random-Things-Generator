//
//  HomeView.swift
//  HomeView
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

class UserPreferences: ObservableObject {
  @Published var themeColor: Color = .blue {
    didSet { saveUserDefaults(value: themeColor.hex, key: themeColorDefaults) }
  }
  @Published var showsRandomButton = true {
    didSet { saveUserDefaults(value: showsRandomButton, key: randomButtonDefaults) }
  }
  @Published var hasHapticFeedback = true {
    didSet { saveUserDefaults(value: hasHapticFeedback, key: hapticFeedbackDefaults) }
  }
  let defaults = UserDefaults.standard
  var textColor: Color {
    themeColor.isLight ? .black : .white
  }
  func saveUserDefaults(value: Any, key: String) {
    defaults.set(value, forKey: key)
  }
  init() {
    themeColor = Color(hex: defaults.object(forKey: themeColorDefaults) as? Int ?? Color.blue.hex)
    showsRandomButton = defaults.object(forKey: randomButtonDefaults) as? Bool ?? true
    hasHapticFeedback = defaults.object(forKey: hapticFeedbackDefaults) as? Bool ?? true
  }
  private var themeColorDefaults = "theme_color"
  private var randomButtonDefaults = "shows_random_button"
  private var hapticFeedbackDefaults = "has_haptic_feedback"
}

struct HomeView: View {
  let types = ["Number", "Word", "Card", "Coin", "Date", "Password"]
  @EnvironmentObject var preferences: UserPreferences
  @State private var settingsPresented = false
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          ForEach(0..<(types.count+1)/2) { num in
            HStack(spacing: 20) {
              HomeViewItem(item: types[num*2], color: preferences.themeColor, destinationView: AnyView(typeToView[types[num*2]]))
              if num*2+1 < types.count {
                HomeViewItem(item: types[num*2+1], color: preferences.themeColor, destinationView: AnyView(typeToView[types[num*2+1]]))
              }
            }
            .padding([.leading, .trailing])
          }
          Button("Press") {
            let r = Double.random(in: 0...255)/255
            let g = Double.random(in: 0...255)/255
            let b = Double.random(in: 0...255)/255
            let color = Color(red: r, green: g, blue: b, opacity: 1)
            print(color)
            print(preferences.themeColor)
            preferences.themeColor = color
            print(preferences.themeColor)
          }
        }
        
      }
      .navigationBarTitle("Random")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            print("pressed")
            settingsPresented = true
          } label: {
            Image(systemName: "gear")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(preferences.themeColor)
          }
          .sheet(isPresented: $settingsPresented) {
            SettingsMenu()
          }
        }
      }
    }
  }
  let typeToView: [String: AnyView] = ["Number": AnyView(NumberGenerator()), "Coin": AnyView(CoinFlipper()), "Card": AnyView(CardRandomizer())]
}

private struct HomeViewItem: View {
  let item: String
  let color: Color
  let destinationView: AnyView
  var body: some View {
    NavigationLink {
      destinationView
    } label: {
      Text(item)
        .font(.title)
        .fontWeight(.semibold)
        .foregroundColor(color.isLight ? .black : .white)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
    .background(color)
    .cornerRadius(15)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
