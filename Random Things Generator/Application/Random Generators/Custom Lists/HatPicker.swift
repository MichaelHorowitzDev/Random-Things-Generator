//
//  HatPicker.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/7/21.
//

import SwiftUI
import CSV

class HotPickerViewModel: ObservableObject {
  @Published var generatedItems = [String]()
}

struct HatPicker: View {
  let totalItems: Int
  @State private var remainingItems: [String]
  @State private var randomItem = "?"
  @State private var scale: CGFloat = 1
  @EnvironmentObject var preferences: UserPreferences
  @StateObject var viewModel = HotPickerViewModel()
  @State private var presentHistory = false
  @State private var shareItem: Item? = nil
  
  init(items: [String]) {
    _remainingItems = State(initialValue: items)
    totalItems = items.count
  }
    var body: some View {
      RandomGeneratorView("Hat Picker") {
        VStack {
          Text("Remaining items: \(remainingItems.count)")
            .font(.title)
          Spacer()
        }
        .padding(.top)
        Text(randomItem)
          .font(.system(size: 100))
          .minimumScaleFactor(0.2)
          .lineLimit(1)
          .foregroundColor(preferences.textColor)
          .scaleEffect(scale)
          .padding(.horizontal, 30)
      }
      .onRandomPressed {
        if remainingItems.count > 0 {
          let randomIndex = Int.random(in: 0..<remainingItems.count)
          let randomItem = remainingItems[randomIndex]
          remainingItems.remove(at: randomIndex)
          self.randomItem = randomItem
          self.viewModel.generatedItems.append(randomItem)
        }
      }
      .onRandomTouchDown {
        scale = 0.9
      }
      .onRandomTouchUp {
        scale = 1
      }
      .onSettingsPressed {
        presentHistory = true
      }
      .sheet(isPresented: $presentHistory) {
        NavigationView {
          List((0..<viewModel.generatedItems.count).reversed(), id: \.self) {
            Text(viewModel.generatedItems[$0])
          }
          .navigationTitle("Picked Items")
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button (action: {
                let tempDirectory = NSTemporaryDirectory()
                let tempURL = URL(fileURLWithPath: tempDirectory, isDirectory: true).appendingPathComponent("lists_hat_picker_\(UUID().uuidString.prefix(8)).csv")
                print(tempURL)
                let stream = OutputStream(toFileAtPath: tempURL.path, append: false)!
                let csv = try! CSVWriter(stream: stream)
                for item in viewModel.generatedItems {
                  try! csv.write(row: [item])
                }
                csv.stream.close()
                shareItem = Item(url: tempURL)
              }, label: {
                Image(systemName: "square.and.arrow.up").foregroundColor(preferences.themeColor)
              })
            }
            ToolbarItem(placement: .navigationBarLeading) {
              Button {
                presentHistory = false
              } label: {
                Text("Done")
                  .bold()
                  .foregroundColor(preferences.themeColor)
              }

            }
          }
          .sheet(item: $shareItem, onDismiss: {
            shareItem = nil
          }, content: { item in
            ShareSheet(activityItems: [item.url])
          })
        }
        
      }
    }
}

private struct Item: Identifiable {
    let id = UUID()
    let url: URL
}
