//
//  HomeView.swift
//  HomeView
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

class UserPreferences: ObservableObject {
  @Published var themeColor: Color = .blue
  @Published var showsRandomButton = true
  @Published var hasHapticFeedback = true
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
              HomeViewItem(item: types[num], destinationView: AnyView(typeToView[types[num]]))
              if num+1 < types.count {
                HomeViewItem(item: types[num+1], destinationView: AnyView(typeToView[types[num+1]]))
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
  let typeToView = ["Number":NumberGenerator()]
}

private struct HomeViewItem: View {
  let item: String
  @EnvironmentObject var preferences: UserPreferences
  let destinationView: AnyView
  var body: some View {
    NavigationLink {
      destinationView
    } label: {
      Text(item)
        .font(.title)
        .fontWeight(.semibold)
        .foregroundColor(preferences.themeColor.isLight ? .black : .white)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
    .background(preferences.themeColor)
    .cornerRadius(15)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
