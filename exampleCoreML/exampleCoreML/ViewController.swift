//
//  ViewController.swift
//  exampleCoreML
//
//  Created by Will Lowry on 7/15/19.
//  Copyright © 2019 Programmer Alley. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var classificationImageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }

    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            classificationImageView.image = pickedImage
        
            // Convert image taken from camera to CIImage class.
            guard let ciimage = CIImage(image: pickedImage) else {
                fatalError("There was an error in converting UIImage to CIImage.")
            }
            
            processImage(image: ciimage)
        
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    
    func processImage(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Error occured when loading Core ML model.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error occured when processing image.")
            }
            
            if let result = results.first {
                self.classificationLabel.text = result.identifier
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

