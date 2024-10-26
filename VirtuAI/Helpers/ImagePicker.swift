//
//  ImagePicker.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.12.2023.
//

import Foundation
import SwiftUI
import Vision
import PhotosUI
import TOCropViewController



struct ImageCropper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var recognizedText: String
    @State private var selectedImage: UIImage?
    @State private var showingCropViewController = false

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        if showingCropViewController, let selectedImage = selectedImage {
            let cropViewController = TOCropViewController(croppingStyle: .default, image: selectedImage)
            cropViewController.delegate = context.coordinator
            uiViewController.present(cropViewController, animated: true, completion: {
                self.showingCropViewController = false
            })
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
        var parent: ImageCropper

        init(_ parent: ImageCropper) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.selectedImage = selectedImage
                parent.showingCropViewController = true
            } else {
                parent.isPresented = false
            }
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.selectedImage = image
            recognizeText(from: image)
            cropViewController.dismiss(animated: true) {
                self.parent.isPresented = false
            }
        }

        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            cropViewController.dismiss(animated: true) {
                self.parent.isPresented = false
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }

        private func recognizeText(from image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                DispatchQueue.main.async {
                    self?.parent.recognizedText = recognizedStrings.joined(separator: "\n")
                }
            }
            request.recognitionLevel = .accurate

            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? requestHandler.perform([request])
        }
    }
}
