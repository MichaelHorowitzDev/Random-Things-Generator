//
//  SettingsMenu.swift
//  SettingsMenu
//
//  Created by Michael Horowitz on 8/27/21.
//

import SwiftUI

struct SettingsMenu: View {
  @EnvironmentObject var preferences: UserPreferences
    var body: some View {
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
      }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
