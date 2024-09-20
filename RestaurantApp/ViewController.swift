//
//  ViewController.swift
//  MyProject
//
//  Created by MELİS on 10.08.2024.
//

import UIKit
import MapKit
import CoreLocation

class MenuListController: UITableViewController{
    var items = ["Profile","Favorite Restaurants","My Reservations"]
    var color = UIColor(cgColor: .init(red: 0.239, green: 0.349, blue: 0.325, alpha: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = color
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.backgroundColor = color
        cell.textLabel?.textColor = .white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[indexPath.row] == "Profile" {
            profileSegue()
        }else if items[indexPath.row] == "Favorite Restaurants"{
            favsSegue()
        }else if items[indexPath.row] == "My Reservations"{
            reservationsSegue()
        }
    }
    
    func profileSegue(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        //vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func favsSegue(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FavRestaurantsVC") as! FavRestaurantsVC
        //vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func reservationsSegue(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyReservationsVC") as! MyReservationsVC
        //vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var RestaurantsTableView: UITableView!

    var locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var restaurants: [Restaurant] = []
    var annotationsDictionary: [String: MKAnnotation] = [:]
    var selectedR: Restaurant?
    var menu: SideMenuNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        searchBar.delegate = self
        RestaurantsTableView.delegate = self
        RestaurantsTableView.dataSource = self
        searchBar.returnKeyType = .search
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let menuListController = MenuListController()
        
        menu = SideMenuNavigationController(rootViewController: MenuListController())
        menu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = menu
        //SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        menu?.isNavigationBarHidden = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Restaurants"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        backButton.tintColor = .white
        
    }
    
    @IBAction func menuTapped(_ sender: Any) {

        present(menu!, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //konum güncelleme
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        //güncellenen konumu haritada gösterme
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        self.searchRestaurants(at: location) { result in
            switch result {
            case .success(let restaurants):
                self.restaurants = restaurants
                for item in self.restaurants {
                    print("Found restaurant: \(item.name)")
                    print(item.address as Any)
                    print(item.categories)
                    print(item.distance as Any)
                    print(item.id)
                    print(item.phone as Any)

                    self.addAnnotation(for: item)
                }
                DispatchQueue.main.async {
                    self.RestaurantsTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching restaurants: \(error.localizedDescription)")
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Klavyeyi kapat
            searchBar.resignFirstResponder()
        
        if let searchTxt = searchBar.text, searchTxt != "" {
            geocoder.geocodeAddressString(searchTxt) { (placemarks, error) in
                if let error = error {
                    print("Geocode failed: \(error.localizedDescription)")
                                return
                }
                //girilen konumu al
                if let placemarks = placemarks, let location = placemarks.first?.location {
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    //haritada konumlandır
                    let location2d = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: location2d, span: span)
                    self.mapView.setRegion(region, animated: true)
                    self.searchRestaurants(at: location2d) { result in
                        switch result {
                        case .success(let restaurants):
                            self.restaurants = restaurants
                            for item in self.restaurants {
                                print("Found restaurant: \(item.name)")
                                print("Latitude: \(latitude)")
                                print("Longitude: \(longitude)")
                                print(item.address as Any)
                                print(item.categories)
                                print(item.distance as Any)
                                print(item.id)
                                print(item.phone as Any)

                                self.addAnnotation(for: item)
                            }
                            DispatchQueue.main.async {
                                self.RestaurantsTableView.reloadData()
                            }
                        case .failure(let error):
                            print("Error fetching restaurants: \(error.localizedDescription)")
                        }
                    }
                    
                    print("Coordinates: Latitude = \(latitude), Longitude = \(longitude)")

                }else{
                    print("No location found.")

                }
                
            }
        }
    }
    

    func addAnnotation(for mapItem: Restaurant) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapItem.coordinate!
        annotation.title = mapItem.name
        annotationsDictionary[mapItem.id] = annotation
        mapView.addAnnotation(annotation)
        
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RestaurantsTableView.dequeueReusableCell(withIdentifier: "RestaurantCell",for: indexPath)
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        

        let restaurant = restaurants[indexPath.section]
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = UIImage(named: "noimage") // Clear the previous image

            if let imageUrl = URL(string: restaurant.imageUrl!) {
                // Perform the image loading asynchronously
                URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    DispatchQueue.main.async {
                        // Update the image view on the main thread
                        if let downloadedImage = UIImage(data: data) {
                            imageView.image = downloadedImage
                        }
                    }
                }.resume()
            }
        }
        
        if let nameLabel = cell.viewWithTag(2) as? UILabel {
            nameLabel.text = restaurant.name
        }
        
        if let ratingLabel = cell.viewWithTag(3) as? UILabel {
            let fullStar = "★ "
            let ratingText = " \(restaurant.rating ?? 0.0)"
            
            // Attributes for the star (color and font)
            let starAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.systemYellow, // Yellow color
                .font: UIFont.systemFont(ofSize: 12) // Font size
            ]
            
            // Create the star attributed string
            let starAttributedString = NSAttributedString(string: fullStar, attributes: starAttributes)
            
            // Create the rating text attributed string
            let ratingAttributedString = NSAttributedString(string: ratingText, attributes: nil)
            
            // Combine them together
            let attributedString = NSMutableAttributedString()
            attributedString.append(starAttributedString) // Append the star first
            attributedString.append(ratingAttributedString) // Append the rating text after
            
            // Set the attributed text to the label
            ratingLabel.attributedText = attributedString
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRestaurant = restaurants[indexPath.section]
        if let annotation = annotationsDictionary[selectedRestaurant.id] {
            mapView.selectAnnotation(annotation, animated: true)
            mapView.setCenter(annotation.coordinate, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectedR = restaurants[indexPath.section]
        Task {
            selectedR = await fetchRestaurantDetails(for: selectedR!.id)
            //let sID = selectedR?.id
            performSegue(withIdentifier: "toRestaurantDetails", sender: nil)
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let title = view.annotation?.title else{ return}
        
        if let index = restaurants.firstIndex(where: { $0.name == title }) {
            RestaurantsTableView.selectRow(at: IndexPath(row: 0, section: index), animated: true, scrollPosition: UITableView.ScrollPosition.middle)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRestaurantDetails" {
            let destinationVC = segue.destination as! RestaurantDetailVC
                destinationVC.selectedRestaurant = selectedR!
        }

    }
    

}



