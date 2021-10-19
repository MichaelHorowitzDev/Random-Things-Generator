//
//  SettingsMenu.swift
//  SettingsMenu
//
//  Created by Michael Horowitz on 8/27/21.
//

import SwiftUI
import MessageUI

struct SettingsMenu: View {
  @EnvironmentObject var preferences: UserPreferences
  @Environment(\.presentationMode) var presentationMode
  @State private var showsMail = false
  @State private var result: Result<MFMailComposeResult, Error>? = nil
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
            NavigationLink {
              ThemeColor()
            } label: {
              Image(systemName: "paintbrush.fill")
              Text("Theme")
            }
          }
          Section("Support") {
            Button("Send Email") {
              if MFMailComposeViewController.canSendMail() {
                showsMail = true
              }
            }
            .sheet(isPresented: $showsMail) {
              let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
              MailView { result in
                print(result)
              }
              .setToRecipients(["michaelhorowitzdev@gmail.com"])
              .setMessageBody("<p><br><br><br><br>Version \(version)</p>", isHTML: true)
              .setSubject("Random Things Generator")
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
      .accentColor(preferences.themeColor)
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
