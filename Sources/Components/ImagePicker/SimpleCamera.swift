//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/10.
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)
struct SimpleCamera: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var isPresented
    let capureCallback: (SFImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

// Coordinator will help to preview the selected image in the View.
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: SimpleCamera
    
    init(picker: SimpleCamera) {
        self.picker = picker
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let selectedImage = info[.originalImage] as? SFImage else { return }
        self.picker.capureCallback(selectedImage)
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
#endif