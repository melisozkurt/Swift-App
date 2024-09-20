//
//  RestaurantDetailVC.swift
//  MyProject
//
//  Created by MELİS on 12.08.2024.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

class RestaurantDetailVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var restaurantImgView: UIImageView!
    @IBOutlet weak var RestaurantNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var isOpenNowLabel: UILabel!
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var locationContainerView: UIView!
    @IBOutlet weak var WhContainerView: UIView!
    //@IBOutlet weak var segmentContol: UISegmentedControl!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedRestaurant: Restaurant!
    var reservation: Reservation?
    var savedRestaurants: [String] = []
    
    var db = Firestore.firestore()

    override func viewWillAppear(_ animated: Bool) {

        fetchSavedRestaurants { favRestaurants in
            if let favRestaurants = favRestaurants{
                self.savedRestaurants = favRestaurants
                if (self.savedRestaurants.contains(self.selectedRestaurant.id)) != false {
                    self.saveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                }
            }else{
                print("no fav rest")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem()
        navigationItem.backBarButtonItem = backButton
        backButton.isEnabled = false
        backButton.isHidden = true
        
        print(selectedRestaurant.id)

        locationContainerView.isHidden = false
        WhContainerView.isHidden = true

        RestaurantNameLabel.text = selectedRestaurant?.name
        restaurantImgView.image = UIImage(named: "noimage") // Clear the previous image

        if let imageUrl = URL(string: selectedRestaurant!.imageUrl!) {
            // Perform the image loading asynchronously
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                DispatchQueue.main.async {
                    // Update the image view on the main thread
                    if let downloadedImage = UIImage(data: data) {
                        self.restaurantImgView.image = downloadedImage
                    }
                }
            }.resume()
        }
        
        
        if let p = selectedRestaurant?.price {
            priceLabel.text = p
        }else{
            priceLabel.text = "-"
        }
        
        categoriesLabel.text = selectedRestaurant.categories.joined(separator: " | ")
        if let address = selectedRestaurant.address {
            addressLabel?.text = "Address: \(address)"
        }
        if let phone = selectedRestaurant.phone {
            phoneLabel?.text = "Phone: \(phone)"
        }
        
        if let isOpen = selectedRestaurant.isOpenNow {
            if isOpen == false{
                isOpenNowLabel.text = "CLOSED NOW"
                isOpenNowLabel.textColor = .red
            }else{
                isOpenNowLabel.text = "OPEN NOW"
                isOpenNowLabel.textColor = UIColor(cgColor: CGColor(red: 0.285, green: 0.634, blue: 0.467, alpha: 1))
            }
        }
        
        let fullStar = "★"
        var ratingText = "Rating: - "
        if let rating = selectedRestaurant.rating{
            ratingText = "Rating: \(rating) "
        }
        
        let attributedString = NSMutableAttributedString(string: ratingText)
        
        // Attributes for the star (color and font)
        let starAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemYellow, // Yellow color
            .font: UIFont.systemFont(ofSize: 16) // Font size
        ]
        
        let starAttributedString = NSAttributedString(string: fullStar, attributes: starAttributes)
        
        // Append the star to the rating text
        attributedString.append(starAttributedString)
        
        ratingLabel.attributedText = attributedString
        
    }
    

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        
        switch selectedIndex {
        case 0:
            locationContainerView.isHidden = false
            WhContainerView.isHidden = true
        case 1:
            locationContainerView.isHidden = true
            WhContainerView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func reservationButtonClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "toBookingVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toBookingVC"{
            let dvc = segue.destination as! BookingViewController
            dvc.restaurantDetail = self.selectedRestaurant
        }
        
        if segue.identifier == "toLocation"{
            let destinationVC = segue.destination as! LocationViewController
            destinationVC.SelectedRest = selectedRestaurant!
        }
        
        if segue.identifier == "toWorkingHours" {
            let destinationVC = segue.destination as! WorkingHoursViewController
            destinationVC.restaurant = self.selectedRestaurant
            print("Restaurant set to: \(String(describing: self.selectedRestaurant))")
        }

    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let user = Auth.auth().currentUser
        else {
            return
        }
        
        if (savedRestaurants.contains(selectedRestaurant.id)) == true{
            let userRef = db.collection("users").document(user.uid)
            userRef.updateData(["favorite restaurants": FieldValue.arrayRemove([selectedRestaurant.id])]) { error in
                    if let error = error {
                        print("Error removing restaurant: \(error.localizedDescription)")
                    }else{
                        self.saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                        self.savedRestaurants.removeAll { $0 == self.selectedRestaurant.id }
                    }
            }
        }else{
            let userRef = db.collection("users").document(user.uid)
            userRef.updateData([
                "favorite restaurants": FieldValue.arrayUnion([selectedRestaurant.id])]) { error in
                    if let error = error {
                        print("Error saving restaurant: \(error.localizedDescription)")
                    }else{
                        self.saveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                        self.savedRestaurants.append(self.selectedRestaurant.id)
                    }
            }
        }
    }
    
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
