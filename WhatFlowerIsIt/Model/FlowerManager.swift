//
//  FlowerManager.swift
//  WhatFlowerIsIt
//
//  Created by Michael Knych on 7/1/22.
//

import Foundation

protocol FlowerManagerDelegate {
    func didUpdateFlower(_ flowerManager: FlowerManager, extract: String, imageURL: String)
    func didFailWithError(_ flowerManager: FlowerManager, error: Error)
}

class FlowerManager {
    var delegate: FlowerManagerDelegate?
    
    func requestInfo(flowerName: String) {
        
        let wikipediaURl = "https://en.wikipedia.org/w/api.php"
        let convertFlowerNmae = flowerName.replacingOccurrences(of: " ", with: "%20")
        let urlString = ("\(wikipediaURl)?format=json&action=query&prop=extracts%7Cpageimages&pithumbsize=500&exintro&explaintext&redirects=1&titles=\(convertFlowerNmae)")
        
        //print(urlString)
        
        performRequest(with: urlString)
        
    }
    
    func performRequest(with urlString: String) {
        // 1. Create URL
        
        if let url = URL(string: urlString) {
            // 2. Create a URLSession
            
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(self, error: error!)
                    return
                }
                
                if let safedata = data {
                    
                    //let response = String(data: safedata, encoding: .utf8)
                    //print(response!)
                   
                    self.parseJSON(safedata)

                }
            }
            
            // Start the task
            task.resume()
            
        }
    }
    
    func parseJSON(_ flowerData: Data) {
        
        let decoder = JSONDecoder()
        
        do {
            // Decode the pages disctionay from the JSON
            let decodedData = try decoder.decode(FlowerData.self, from: flowerData).query.pages
            
            // Get the first disctionay key
            if let pageKey = decodedData.first?.key {
                // results is the page pointed to by the key
                // (i.e. the pageid)
                let results = decodedData[pageKey]!
                let flowerDescription = results.extract
                let flowerImageURL = results.thumbnail.source
                //print(flowerDescription)
                //print(flowerImageURL)
                
                self.delegate?.didUpdateFlower(self, extract: flowerDescription, imageURL: flowerImageURL)
                
                
            }
        } catch {
            print(error)
            
        }
        
    }    
    
}


