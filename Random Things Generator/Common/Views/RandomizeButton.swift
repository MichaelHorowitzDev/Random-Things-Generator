//
//  RandomizeButton.swift
//  RandomizeButton
//
//  Created by Michael Horowitz on 8/26/21.
//

import SwiftUI

struct RandomizeButton: View {
  let buttonTitle: String
  let buttonPressed: () -> ()
  var body: some View {
    Button {
      buttonPressed()
    } label: {
      Text("Randomize")
        .foregroundColor(.black)
        .font(.title)
        .fontWeight(.medium)
    }
    .frame(height: 70)
    .frame(maxWidth: .infinity)
    .background(Color.white)
    .cornerRadius(15)
    .padding()
  }
}

//struct RandomizeButton_Previews: PreviewProvider {
//  static var previews: some View {
//    RandomizeButton()
//  }
//}
