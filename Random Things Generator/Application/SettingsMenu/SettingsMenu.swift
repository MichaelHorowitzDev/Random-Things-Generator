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
  @State private var emailCopied = false
  @State private var showsShareSheet = false
    var body: some View {
      NavigationView {
        List {
          Section("General") {
            HStack {
              Image(systemName: "waveform")
              Spacer()
              Toggle("Haptics", isOn: $preferences.hasHapticFeedback)
                .tint(preferences.themeColor)
            }
            HStack {
              Image(systemName: "hand.tap.fill")
              Spacer()
              Toggle("Tap to Randomize", isOn: !$preferences.showsRandomButton)
                .tint(preferences.themeColor)
            }
          }
          Section("Customization") {
            NavigationLink {
              ThemeColor()
            } label: {
              Image(systemName: "paintbrush.fill")
              Text("Theme")
            }
            if UIApplication.shared.supportsAlternateIcons {
              NavigationLink {
                AppIcon()
              } label: {
                Image(systemName: "plus.square.dashed")
                Text("App Icon")
              }
            }
          }
          Section("Support") {
            Button {
              if MFMailComposeViewController.canSendMail() {
                showsMail = true
              } else {
                UIPasteboard.general.string = "michaelhorowitzdev@gmail.com"
                emailCopied = true
              }
            } label: {
              HStack {
                Text("Send Email")
                Spacer()
                Image(systemName: "paperplane")
              }
            }
            .alert("Email Copied", isPresented: $emailCopied, actions: {
              Button("OK", role: .cancel) {}
            }, message: {
              Text("You can now paste it wherever needed.")
            })
            .sheet(isPresented: $showsMail) {
              let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
              MailView { result in
                print(result)
              }
              .setToRecipients(["michaelhorowitzdev@gmail.com"])
              .setMessageBody("<p><br><br><br><br>Version \(version)</p>", isHTML: true)
              .setSubject("Random Things Generator")
            }
            if let url = URL(string: "https://itunes.apple.com/us/app/random-things-generator/id1460779766"), UIApplication.shared.canOpenURL(url) {
              Button {
                UIApplication.shared.open(url.appendingPathComponent("?action=write-review"))
              } label: {
                HStack {
                  Text("Rate App")
                  Spacer()
                  Image(systemName: "star")
                }
              }
              Button {
                showsShareSheet = true
              } label: {
                HStack {
                  Text("Share")
                  Spacer()
                  Image(systemName: "square.and.arrow.up")
                }
              }
              .sheet(isPresented: $showsShareSheet) {
                ShareSheet(activityItems: ["Check out the Random Things Generator App on the App Store!", url])
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
      .accentColor(preferences.themeColor)
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
