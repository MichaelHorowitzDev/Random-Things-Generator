//
//  HomeView.swift
//  HomeView
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

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
  }
  private var themeColorDefaults = "theme_color"
  private var randomButtonDefaults = "shows_random_button"
  private var hapticFeedbackDefaults = "has_haptic_feedback"
}

struct HomeView: View {
  let types = ["Number", "Card", "Coin", "Date", "Map", "Lists"]
  @EnvironmentObject var preferences: UserPreferences
  @State private var settingsPresented = false
  let columns: [GridItem] = [GridItem(.adaptive(minimum: 140))]
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(0..<types.count) { num in
            HomeViewItem(item: types[num], color: preferences.themeColor, destinationView: AnyView(typeToView[types[num]]))
              .padding(.horizontal, 5)
          }
        }
        .padding(.horizontal, 10)
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
    .navigationViewStyle(.stack)
    .accentColor(preferences.themeColor)
  }
  let typeToView: [String: AnyView] = ["Number": AnyView(NumberGenerator()), "Coin": AnyView(CoinFlipper()), "Card": AnyView(CardRandomizer()), "Date": AnyView(DateGenerator()), "Map": AnyView(MapGenerator()), "Lists": AnyView(ListsGenerator())]
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
    .cornerRadius(10)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
