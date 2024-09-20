//
//  Restaurant.swift
//  MyProject
//
//  Created by MELİS on 12.08.2024.
//

import Foundation
import CoreLocation

struct Restaurant {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D?
    let rating: Double?
    let imageUrl: String?
    let categories: [String]
    let distance: Double?
    let phone: String?
    let address: String?
    let price: String?
    let isClaimed: Bool?
    let isClosed: Bool?
    let url: String?
    let reviewCount: Int?
    let operatingHours: [OperatingHours]?
    let isOpenNow: Bool?

    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
              let name = json["name"] as? String,
              let categories = json["categories"] as? [[String: Any]]
        else {
            return nil
        }

        self.id = id
        self.name = name
        self.categories = categories.compactMap { $0["title"] as? String }

        if let coordinates = json["coordinates"] as? [String: Any],
           let latitude = coordinates["latitude"] as? Double,
           let longitude = coordinates["longitude"] as? Double {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }else{
            self.coordinate = nil
        }

        self.rating = json["rating"] as? Double
        self.imageUrl = json["image_url"] as? String
        self.distance = json["distance"] as? Double
        self.phone = json["display_phone"] as? String
        
        if let location = json["location"] as? [String: Any],
           let displayAddress = location["display_address"] as? [String] {
            self.address = displayAddress.joined(separator: ", ")
        } else {
            self.address = nil
        }
        
        self.price = json["price"] as? String
        self.isClaimed = json["is_claimed"] as? Bool
        self.isClosed = json["is_closed"] as? Bool
        self.url = json["url"] as? String
        self.reviewCount = json["review_count"] as? Int

        if let hoursArray = json["hours"] as? [[String: Any]],
           let openArray = hoursArray.first?["open"] as? [[String: Any]] {
            self.operatingHours = openArray.compactMap { OperatingHours(json: $0) }
            self.isOpenNow = hoursArray.first?["is_open_now"] as? Bool
        } else {
            self.operatingHours = nil
            self.isOpenNow = nil
        }
    }
}

struct OperatingHours {
    let day: Int
    let start: String
    let end: String
    let isOvernight: Bool

    init?(json: [String: Any]) {
        guard let day = json["day"] as? Int,
              let start = json["start"] as? String,
              let end = json["end"] as? String,
              let isOvernight = json["is_overnight"] as? Bool else {
            return nil
        }

        self.day = day
        self.start = start
        self.end = end
        self.isOvernight = isOvernight
    }
}
