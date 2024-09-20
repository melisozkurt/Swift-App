//
//  ReservationServer.swift
//  MyProject
//
//  Created by MELİS on 29.08.2024.
//

import Foundation
import UIKit
import FirebaseAuth

extension UIViewController {
    
    
    func fetchReservationsUser(for userUuid: String, completion: @escaping ([Reservation]?) -> Void) {
        let urlString = "https://dc4c7ba7-c8f3-4342-99c4-c9f769462310-00-1dov29ilfbj6g.pike.replit.dev/reservations/user/\(userUuid)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data returned")
                completion(nil)
                return
            }

            do {
                let reservations = try JSONDecoder().decode([Reservation].self, from: data)
                completion(reservations)
            } catch {
                print("Error decoding reservations: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchReservations(for restaurantId: String, completion: @escaping ([Reservation]?) -> Void) {
        let urlString = "https://dc4c7ba7-c8f3-4342-99c4-c9f769462310-00-1dov29ilfbj6g.pike.replit.dev/reservations/restaurant/\(restaurantId)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let reservations = try JSONDecoder().decode([Reservation].self, from: data)
                completion(reservations)
            } catch {
                print("Error decoding reservations: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func sendReservation(_ reservation: Reservation, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://dc4c7ba7-c8f3-4342-99c4-c9f769462310-00-1dov29ilfbj6g.pike.replit.dev/reservations"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(reservation)
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        } // Call completion with nil on error
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                            if let data = data {
                                do {
                                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                       let reservationId = jsonResponse["id"] as? String {
                                        DispatchQueue.main.async {
                                            completion(.success(reservationId))
                                        }
                                        print("Response status code: \(httpResponse.statusCode)")
                                    } else {
                                        print("Error: Unexpected response format")
                                        DispatchQueue.main.async {
                                            completion(.failure(error!))
                                        }
                                    }
                                } catch {
                                    print("Error parsing response: \(error)")
                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }
                            }
                    }
                }
            }.resume()
        } catch {
            DispatchQueue.main.async {
                print("Error encoding reservation: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    
    
    func updateReservation(_ reservation: Reservation, for id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://dc4c7ba7-c8f3-4342-99c4-c9f769462310-00-1dov29ilfbj6g.pike.replit.dev/reservations/\(id)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(reservation)
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } else {
                        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    func deleteReservation(withId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://dc4c7ba7-c8f3-4342-99c4-c9f769462310-00-1dov29ilfbj6g.pike.replit.dev/reservations/\(id)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                case 404:
                    let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reservation not found"])
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                default:
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }

}
