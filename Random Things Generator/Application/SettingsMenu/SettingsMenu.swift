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
  @State private var emailCopied = false
  @State private var showsShareSheet = false
    var body: some View {
      NavigationView {
        List {
          Section {
            HStack {
              Image(systemName: "waveform")
              Spacer()
              Toggle("Haptics", isOn: $preferences.hasHapticFeedback)
//                .tint(preferences.themeColor)
            }
            HStack {
              Image(systemName: "hand.tap.fill")
              Spacer()
              Toggle("Tap to Randomize", isOn: !$preferences.showsRandomButton)
//                .tint(preferences.themeColor)
            }
            HStack {
              Image(systemName: "iphone.radiowaves.left.and.right")
              Spacer()
              Toggle("Shake to Randomize", isOn: $preferences.hasShakeToGenerate)
//                .accentColor(preferences.themeColor)
//                .tint(preferences.themeColor)
            }
            
          } header: {
            Text("General")
          }
          .toggleStyle(SwitchToggleStyle(tint: preferences.themeColor))
          Section {
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
            NavigationLink {
              ReorganizeGenerators()
            } label: {
              Image(systemName: "arrow.up.arrow.down.square")
              Text("Reorganize")
            }
          } header: {
            Text("Customization")
          }
          Section {
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
            .alert(isPresented: $emailCopied, content: {
              Alert(title: Text("Email Copied"), message: Text("You can now paste it wherever needed."), dismissButton: .cancel(Text("OK")))
            })
//            .alert("Email Copied", isPresented: $emailCopied, actions: {
//              Button("OK", role: .cancel) {}
//            }, message: {
//              Text("You can now paste it wherever needed.")
//            })
            .sheet(isPresented: $showsMail) {
              let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
              MailView()
              .setToRecipients(["michaelhorowitzdev@gmail.com"])
              .setMessageBody("<p><br><br><br><br>Version \(version)</p>", isHTML: true)
              .setSubject("Random Things Generator")
            }
            if let url = URL(string: "https://itunes.apple.com/us/app/random-things-generator/id1460779766?action=write-review"), UIApplication.shared.canOpenURL(url) {
              Button {
                UIApplication.shared.open(url)
              } label: {
                HStack {
                  Text("Rate App")
                  Spacer()
                  Image(systemName: "star")
                }
              }
            }
            if let url = URL(string: "https://itunes.apple.com/us/app/random-things-generator/id1460779766"), UIApplication.shared.canOpenURL(url) {
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
          } header: {
            Text("Support")
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
