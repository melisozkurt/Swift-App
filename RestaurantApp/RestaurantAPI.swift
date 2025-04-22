//
//  RestaurantAPI.swift
//  MyProject
//
//  Created by MELİS on 29.08.2024.
//

import Foundation
import UIKit
import FirebaseAuth
import CoreLocation

extension UIViewController {
    
    func searchRestaurants(at coordinate: CLLocationCoordinate2D, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "radius", value: "1000"),
            URLQueryItem(name: "categories", value: "restaurants"),
            URLQueryItem(name: "sort_by", value: "best_match"),
            URLQueryItem(name: "limit", value: "20"),
        ]
        components.queryItems = components.queryItems ?? [] + queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "API-Key"
        ]

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
                
                if let dictionary = json as? [String: Any], let businesses = dictionary["businesses"] as? [[String: Any]] {
                    var uniqueRestaurants = [Restaurant]()
                    var restaurantNames = Set<String>()
                    
                    for business in businesses {
                        if let restaurant = Restaurant(json: business), !restaurantNames.contains(restaurant.name) {
                            uniqueRestaurants.append(restaurant)
                            restaurantNames.insert(restaurant.name)
                        }
                    }
                    
                    uniqueRestaurants = sortRestaurantsByDistance(restaurants: uniqueRestaurants)
                    completion(.success(uniqueRestaurants))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }


    
    func sortRestaurantsByDistance(restaurants: [Restaurant]) -> [Restaurant] {
        return restaurants.sorted { $0.distance! < $1.distance! }
    }
    

    
    func fetchRestaurantDetails(for restaurantId: String) async -> Restaurant? {
        let urlString = "https://api.yelp.com/v3/businesses/\(restaurantId)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer 6cLSIzeZ2vLddfBeXDlSgJjyLXaawc2pmp9xToiCOHiiATVfPa9PRQ7r0rraOUjv6T4vaqOlmPjeizz4TDvhPpKVUIqNjz_CtKlbzYkjX3KAmoklZ-Um2ApZtau4ZnYx"
        ]

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Data: \(jsonString)")
            }

            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let restaurantDetail = Restaurant(json: json)
                return restaurantDetail
            } else {
                print("Failed to convert data to JSON.")
                return nil
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func fetchSavedRestaurants(completion: @escaping ([String]?) -> Void) {
        guard let user = Auth.auth().currentUser
        else {
            print("no user found")
            completion([])
            return
        }
        
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { document, error in
            if let error = error {
                print("error: document: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let document = document, document.exists{
                if let favRestaurants = document.get("favorite restaurants") as? [String] {
                    completion(favRestaurants)
                }
            }else{
                print("no document")
                completion([])
            }
        }
    }
}
