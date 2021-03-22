//
//  ViewController.swift
//  notHotDog
//
//  Created by Lahari Ganti on 2/26/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didPressCamera))
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let coreImage = CIImage(image: userPickedImage) else {
                fatalError("could not convert picked image into CIImage")
            }
            detectImgae(image: coreImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }


    func detectImgae(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("training model failed to load")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }

            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.resultLabel.text = "hotdog"
                } else {
                    self.resultLabel.text = "not hotdog"
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @objc func didPressCamera() {
        present(imagePicker, animated: true, completion: nil)
    }
}


