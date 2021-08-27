//
//  SettingsMenu.swift
//  SettingsMenu
//
//  Created by Michael Horowitz on 8/27/21.
//

import SwiftUI

struct SettingsMenu: View {
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.presentationMode) var presentationMode
    var body: some View {
      NavigationView {
        List {
          Section("General") {
            HStack {
              Image(systemName: "waveform")
              Spacer()
              Toggle("Haptics", isOn: $preferences.hasHapticFeedback)
            }
            HStack {
              Image(systemName: "hand.tap.fill")
              Spacer()
              Toggle("Tap to Randomize", isOn: !$preferences.showsRandomButton)
            }
          }
          Section("Customization") {
            HStack {
              Image(systemName: "paintbrush.fill")
              Spacer()
              NavigationLink("Theme") {
                ThemeColor()
              }
            }
          }
        }
        .navigationTitle("Settings")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Text("Done")
                .fontWeight(.bold)
            }

          }
        }
      }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
