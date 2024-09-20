//
//  RestaurantDetail.swift
//  MyProject
//
//  Created by MELİS on 15.08.2024.
//
/*
import Foundation
import CoreLocation

struct RestaurantDetail {
    let id: String
    let name: String
    let imageUrl: String?
    let isClaimed: Bool?
    let isClosed: Bool?
    let url: String?
    let reviewCount: Int?
    let operatingHours: [OperatingHours]?
    let isOpenNow: Bool?
    let categories: [String]

    init?(json: [String: Any]) {
        guard let categories = json["categories"] as? [[String: Any]],
              let id = json["id"] as? String,
              let name = json["name"] as? String,
              let imageUrl = json["image_url"] as? String,
              let isClaimed = json["is_claimed"] as? Bool,
              let isClosed = json["is_closed"] as? Bool,
              let url = json["url"] as? String,
              let reviewCount = json["review_count"] as? Int
        else{
            return nil
        }

        self.id = id
        print(id)
        self.name = name
        print(name)
        self.imageUrl = imageUrl
        print(imageUrl)
        self.isClaimed = isClaimed
        print(isClaimed)
        self.isClosed = isClosed
        print(isClosed)
        self.url = url
        print(url)
        self.reviewCount =  reviewCount
        print(reviewCount)
        self.categories = categories.compactMap { $0["title"] as? String }
        print(categories)
        
        
        if let hoursArray = json["hours"] as? [[String: Any]],
           let openArray = hoursArray.first?["open"] as? [[String: Any]] {
            self.operatingHours = openArray.compactMap { OperatingHours(json: $0) }
            self.isOpenNow = hoursArray.first?["is_open_now"] as? Bool
            print(isOpenNow!)
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
    
    
    
*/
