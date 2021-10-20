//
//  AppIcon.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/20/21.
//

import SwiftUI

private class AppIconName: ObservableObject {
  @Published var name = UIApplication.shared.alternateIconName ?? "default" {
    didSet {
      if name == "default" {
        UIApplication.shared.setAlternateIconName(nil)
      } else {
        UIApplication.shared.setAlternateIconName(name)
      }
    }
  }
}

struct AppIcon: View {
  let names = ["Default", "Bright Red", "Fire", "Orange Red", "Pink", "Purple", "Yellow Orange"]
//  @State private var appIconName = UIApplication.shared.alternateIconName ?? "default"
  @ObservedObject private var iconName = AppIconName()
    var body: some View {
      List(0..<names.count, id: \.self) { name in
        Button {
          if names[name] == "Default" {
            iconName.name = "default"
          } else {
            iconName.name = names[name].lowercased()
          }
        } label: {
          HStack(alignment: .center) {
            Image(names[name])
              .resizable()
              .scaledToFit()
              .frame(height: 80)
              .cornerRadius(18)
              .padding(.trailing)
            Text(names[name])
              .foregroundColor(Color(uiColor: .label))
            Spacer()
            if names[name].lowercased() == iconName.name {
              Image(systemName: "checkmark")
                .foregroundColor(.blue)
                .font(.title3.bold())
            }
          }
        }
      }
      .navigationTitle("App Icon")
      .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon()
    }
}
