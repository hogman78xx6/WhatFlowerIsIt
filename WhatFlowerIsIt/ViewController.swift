//
//  ViewController.swift
//  WhatFlowerIsIt
//
//  Created by Michael Knych on 6/29/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    let imagePicker = UIImagePickerController()
    
    var flowerManager = FlowerManager()
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        flowerManager.delegate = self
        

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not covert UIImage to CIImage")
            }
            
            detect(image: ciImage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    
    }
    

    @IBAction func cameraClick(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: MLModelConfiguration()).model) else {
            fatalError("Loading coreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) {request, error in
            
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Error: cold not return request from model")
            }
            //print(classification)
            
            self.navigationItem.title = classification.identifier.capitalized
            
            // call the FlowerManager class object to go to Wiki and
            // get flower info we just determined from the model
            self.flowerManager.requestInfo(flowerName: classification.identifier)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }

    }

}

extension ViewController: FlowerManagerDelegate {
    func didUpdateFlower(_ flowerManager: FlowerManager, extract: String, imageURL: String) {
        DispatchQueue.main.async {

            self.label.text = extract
            self.imageView.loadFrom(URLAddress: imageURL)
        }
    }
    
    func didFailWithError(_ flowerManager: FlowerManager, error: Error) {
        print(error)
    }
   
}

// extension of UIImageView to include a loadFrom method that loads an
// UIImage from a url string
extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    self?.image = loadedImage
                }
            }
        }
    }
}

