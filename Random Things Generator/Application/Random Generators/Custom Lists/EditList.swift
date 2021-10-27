//
//  EditList.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/26/21.
//

import SwiftUI

struct EditListTitle: View {
  @State private var titleText = ""
  @State private var selectedColor = Color.blue
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) var moc
  @EnvironmentObject var preferences: UserPreferences
  let generatorList: GeneratorList
  init(list: GeneratorList) {
    self.generatorList = list
    _titleText = State(initialValue: list.title ?? "")
    var selectedColor = Color.blue
    if let colorData = list.color, let color = Color.withData(colorData) {
      selectedColor = color
    }
    _selectedColor = State(initialValue: selectedColor)
  }
  var body: some View {
    NavigationView {
      ZStack {
        (Color(.secondarySystemGroupedBackground))
          .edgesIgnoringSafeArea(.all)
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Circle()
              .fill(selectedColor)
              .frame(width: 110, height: 110)
              .padding(20)
            TextField("Edit Title", text: $titleText)
              .font(.title.bold())
              .multilineTextAlignment(.center)
              .disableAutocorrection(true)
              .padding()
              .background(Color(.systemGray3))
              .cornerRadius(15.0)
              .padding([.leading, .trailing, .bottom])
          }
          .background(
            RoundedRectangle(cornerRadius: 15)
              .fill(Color(.tertiarySystemGroupedBackground)))
          .padding()
          VStack {
            HStack(spacing: 0) {
              ColorSelect(color: .red, selectedColor: $selectedColor)
              ColorSelect(color: .orange, selectedColor: $selectedColor)
              ColorSelect(color: .yellow, selectedColor: $selectedColor)
              ColorSelect(color: .green, selectedColor: $selectedColor)
              ColorSelect(color: .blue, selectedColor: $selectedColor)
              ColorSelect(color: .pink, selectedColor: $selectedColor)
              ColorSelect(color: .purple, selectedColor: $selectedColor)
            }
            HStack(spacing: 0) {
              ColorSelect(color: Color(UIColor.magenta), selectedColor: $selectedColor)
              ColorSelect(color: Color(UIColor.cyan), selectedColor: $selectedColor)
              ColorSelect(color: Color(UIColor.brown), selectedColor: $selectedColor)
              ColorSelect(color: .clear, selectedColor: $selectedColor, isClear: true)
              ColorSelect(color: .clear, selectedColor: $selectedColor, isClear: true)
              ColorSelect(color: .clear, selectedColor: $selectedColor, isClear: true)
              ColorSelect(color: .clear, selectedColor: $selectedColor, isClear: true)
            }
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 15)
              .fill(Color(.tertiarySystemGroupedBackground)))
          
          .padding()
          Spacer()
        }
        .navigationBarTitle("Edit List", displayMode: .inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Text("Cancel")
                .foregroundColor(preferences.themeColor)
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button {
//              let fetchRequest: NSFetchRequest<GeneratorList> = GeneratorList.fetchRequest()
//              var canAddItem = false
//              do {
//                let results = try moc.fetch(fetchRequest)
//                let containsTitle = results.contains(where: { $0.title == titleText })
//                if !containsTitle {
//                  canAddItem = true
//                }
//              } catch {
//                print(error)
//                canAddItem = true
//              }
//              if !canAddItem {
//                itemTitleExists = true
//              } else {
              generatorList.title = titleText
              generatorList.color = selectedColor.data
              try? self.moc.save()
              presentationMode.wrappedValue.dismiss()
//                let list = GeneratorList(context: self.moc)
//                list.title = titleText
//                list.color = selectedColor.data
//                list.id = UUID()
//                list.dateCreated = Date()
//                list.dateModified = Date()
//                try? self.moc.save()
//                presentationMode.wrappedValue.dismiss()
//              }
            } label: {
              Text("Save")
                .fontWeight(.bold)
                .tint(preferences.themeColor)
            }
            .disabled(titleText == "")
          }
        }
      }
    }
  }
  @State private var itemTitleExists = false
}
private struct ColorSelect: View {
  let size = CGSize(width: 40, height: 40)
  let minSize = CGSize(width: 30, height: 30)
  let color: Color
  @Binding var selectedColor: Color
  var isClear = false
  var body: some View {
    Circle()
      .fill(color)
      .frame(minWidth: minSize.width, idealWidth: size.width, maxWidth: size.width, minHeight: minSize.height, idealHeight: size.height, maxHeight: size.height)
      .padding(3)
      .frame(maxWidth: .infinity)
      .onTapGesture {
        if !isClear {
          selectedColor = color
        }
      }
  }
}
