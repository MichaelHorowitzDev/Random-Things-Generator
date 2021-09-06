//
//  TextFieldAlert.swift
//  TextFieldAlert
//
//  Created by Michael Horowitz on 9/5/21.
//

import SwiftUI

struct TextFieldAlert: UIViewControllerRepresentable {
  
  @Binding var show: Bool
  let title: String?
  let message: String?
  let placeholder: String?
  let onSubmit: (String?) -> Void
  func makeUIViewController(context: Context) -> UIAlertController {
    return UIAlertController(title: title, message: message, preferredStyle: .alert)
  }
  func updateUIViewController(_ uiViewController: UIAlertController, context: Context) {
    guard context.coordinator.alert == nil else { return }
    if self.show {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      context.coordinator.alert = alert
      
      alert.addTextField { textField in
        textField.placeholder = placeholder
      }
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
      })
      alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
        onSubmit(alert.textFields?.first?.text)
      })
      
      DispatchQueue.main.async { // must be async !!
        uiViewController.present(alert, animated: true, completion: {
          self.show = false  // hide holder after alert dismiss
          context.coordinator.alert = nil
        })
      }
    }
  }
    
    func makeCoordinator() -> TextFieldAlert.Coordinator {
      Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
      var alert: UIAlertController?
      var control: TextFieldAlert
      init(_ control: TextFieldAlert) {
        self.control = control
      }
  }
}
