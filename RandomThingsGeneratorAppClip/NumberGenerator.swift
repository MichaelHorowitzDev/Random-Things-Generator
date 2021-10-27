//
//  NumberGenerator.swift
//  RandomThingsGeneratorAppClip
//
//  Created by Michael Horowitz on 10/27/21.
//

import SwiftUI
import Combine

struct NumberGenerator: View {
  @State private var firstNumber = ""
  @State private var secondNumber = ""
  @State private var randomNumber = "?"
  @State private var animationAmount: CGFloat = 1
  @FocusState private var isFocused: Bool
  let textColor = Color.white
  let themeColor = Color.blue
  @State private var showsHistory = false
  @Environment(\.managedObjectContext) var moc
  @FetchRequest(entity: Random.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Random.timestamp, ascending: false)], predicate: NSPredicate(format: "randomType == %@", "Number"), animation: .default) var list: FetchedResults<Random>
//  @State private var settingsPresented = false
    var body: some View {
      NavigationView {
        ZStack {
          themeColor.ignoresSafeArea(.all, edges: [.leading, .trailing, .bottom])
          Group {
            VStack {
              HStack(spacing: 20) {
                NumberEntry(placeholder: "First Number", number: $firstNumber, isFocused: $isFocused)
                  .highPriorityGesture(TapGesture())
                NumberEntry(placeholder: "Second Number", number: $secondNumber, isFocused: $isFocused)
                  .highPriorityGesture(TapGesture())
              }
              .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                  Spacer()
                  Button("Done") {
                    isFocused = false
                  }
                }
              }
              .padding()
              .padding(.top, 50)
              Spacer()
            }
            Text(randomNumber)
              .font(.system(size: 100))
              .minimumScaleFactor(0.2)
              .lineLimit(1)
              .foregroundColor(textColor)
              .padding()
              .scaleEffect(animationAmount)
          }
          .onTapGesture {
            isFocused = false
          }
          VStack {
            Spacer()
            RandomizeButton("Randomize") {
              isFocused = false
              setNumbers()
              guard let num1 = Int(firstNumber) else { return }
              guard let num2 = Int(secondNumber) else { return }
              if num1 > num2 { return }
              let randNum = Int.random(in: num1...num2)
              randomNumber = String(randNum)
              let coreDataItem = Random(context: moc)
              coreDataItem.randomType = "Number"
              coreDataItem.timestamp = Date()
              coreDataItem.value = randomNumber
              try? moc.save()
            }
            .onTouchDown {
              if !isFocused {
                animationAmount = 0.97
              }
            }
            .onTouchUp {
              animationAmount = 1
            }
          }
        }
        .navigationTitle("Number")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              showsHistory = true
            } label: {
              Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeColor)
            }
            .sheet(isPresented: $showsHistory) {
              NavigationView {
                List {
                  Section {
                    ForEach(list, id: \.self) { item in
                      HStack {
                        Text(item.value ?? "")
                          .font(.title)
                        Spacer(minLength: 50)
                        Text(formatDate(date: item.timestamp))
                      }
                    }
                  } header: {
                    Text("Total \(list.count)")
                  }
                }
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.large)
              }
            }
          }
        }
      }
    }
  func formatDate(date: Date?) -> String {
    if date == nil {
      return "Unknown Date"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "M/d/yy"
      let dateString = formatter.string(from: date!)
      formatter.dateFormat = "h:mm:ss a"
      let timeString = formatter.string(from: date!)
      return dateString+"\n"+timeString
    }
  }
  func setNumbers() {
    guard var num1 = Int(firstNumber) else { return }
    guard var num2 = Int(secondNumber) else { return }
    if num1 >= num2 {
      if String(num2+1).count > 10 {
        num1 = num2 - 1
        firstNumber = String(num1)
      } else {
        num2 = num1 + 1
        secondNumber = String(num2)
      }
    }
  }
}

private struct NumberEntry: View {
  let placeholder: String
  @Binding var number: String
  private var isFocused: FocusState<Bool>.Binding
  init(placeholder: String, number: Binding<String>, isFocused: FocusState<Bool>.Binding) {
    self.placeholder = placeholder
    self._number = number
    self.isFocused = isFocused
  }
  var body: some View {
    TextField(placeholder, text: $number)
      .textFieldStyle(.roundedBorder)
      .keyboardType(.numberPad)
      .focused(isFocused)
      .onReceive(Just(number)) { newValue in
        var filtered = newValue.filter {"0123456789".contains($0)}
        if filtered.count > 10 {
          filtered = String(filtered.prefix(10))
        }
        number = filtered
      }
  }
}
