//
//  FlowerData.swift
//  WhatFlowerIsIt
//
//  Created by Michael Knych on 7/1/22.
//

import Foundation

struct FlowerData: Codable {
    
    let query: Query
    
}

struct Query: Codable {
    let pages: [String:Results]
}

struct Results: Codable {
    let pageid: Int
    let extract: String
    let title: String
    let thumbnail : Thumbnail
    let pageimage : String
}

struct Thumbnail: Codable {
    let source: String
    let width: Int
    let height: Int
}
