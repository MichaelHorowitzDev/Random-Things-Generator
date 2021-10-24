//
//  ImagePickerView.swift
//  Random Things Generator
//
//  Created by Michael Horowitz on 10/24/21.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  @Environment(\.presentationMode) var presentationMode
  @Binding var image: UIImage?
  var imageResult: ((UIImage) -> Void)? = nil
  init(image: Binding<UIImage?>) {
    self._image = image
  }
  init(image: @escaping (UIImage) -> Void) {
    self.imageResult = image
    self._image = Binding.constant(nil)
    
  }
  
  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration(photoLibrary: .shared())
    configuration.selectionLimit = 1
    configuration.filter = .any(of: [.images, .livePhotos])
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    
  }
  class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      let itemProviders = results.map(\.itemProvider)
      for item in itemProviders {
        item.loadObject(ofClass: UIImage.self) { (image, error) in
          DispatchQueue.main.async {
            if let image = image as? UIImage {
              if self.parent.imageResult == nil {
                self.parent.image = image
              } else {
                self.parent.imageResult?(image)
              }
            }
          }
        }
      }
      self.parent.presentationMode.wrappedValue.dismiss()
    }
    
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
  }
}
