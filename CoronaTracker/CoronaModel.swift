//
//  CoronaModel.swift
//  CoronaTracker
//
//  Created by Swapnanil Dhol on 3/22/20.
//  Copyright © 2020 Swapnanil Dhol. All rights reserved.
//

import Foundation

struct CoronaModel: Decodable {
    
    let latest: Latest
    let locations: [Location]
}

struct Latest: Decodable {
    
    let confirmed: Int
    let deaths: Int
    let recovered: Int
}

struct Coordinates: Decodable {
    
    let latitude: String
    let longitude: String
    
}
struct Location: Decodable {
    
    let coordinates: Coordinates
    let country: String
    let country_code: String
    let id: Int
    let last_updated: String
    let latest: Latest
    let province: String
    
}
