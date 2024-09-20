//
//  ProfileViewController.swift
//  MyProject
//
//  Created by MELİS on 24.08.2024.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var fullNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backButtonTapped))
        //UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backButtonTapped))
        closeButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = closeButton
        
        fullNameTxtField.isEnabled = false
        emailTxtField.isEnabled = false
        
        if let user = Auth.auth().currentUser {
            fullNameTxtField.text = "\(user.displayName ?? "")"
            emailTxtField.text = "\(user.email ?? "")"
        }else{
            print("no user data")
        }
    }
    
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLogIn", sender: nil)
        }catch{
            print("Error")
        }
    }
    
    @IBAction func EditSaveTapped(_ sender: Any) {
        let name = fullNameTxtField.text
        let email = emailTxtField.text
        
        if fullNameTxtField.isEnabled == false {
            button.setTitle("SAVE", for: .normal)
            button.setTitleColor(.red, for: .normal)
            fullNameTxtField.isEnabled = true
            emailTxtField.isEnabled = true
            fullNameTxtField.backgroundColor = .white
            emailTxtField.backgroundColor = .white
        }else{
            button.configuration?.showsActivityIndicator = true
            if let user = Auth.auth().currentUser {
                user.displayName = fullNameTxtField.text
                user.email = emailTxtField.text
                fullNameTxtField.text = "\(user.displayName ?? "")"
                emailTxtField.text = "\(user.email ?? "")"
            }else{
                print("no user data")
                fullNameTxtField.text = name
                emailTxtField.text = email
            }
            button.setTitle("Edit", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            fullNameTxtField.isEnabled = false
            emailTxtField.isEnabled = false
            fullNameTxtField.backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 0.973, alpha: 1)
            emailTxtField.backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 0.973, alpha: 1)
            button.configuration?.showsActivityIndicator = false
        }
    }
    
}




class FavRestaurantsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var favRestaurants: [Restaurant] = []
    var favIDs: [String] = []
    var selectedRest: Restaurant!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        if favIDs.isEmpty {
            fetchSavedRestaurants { IDs in
                if let IDs = IDs{
                    self.activityIndicator.isHidden = false
                    self.favIDs = IDs
                    Task {
                        for id in self.favIDs {
                            if let restaurant = await self.fetchRestaurantDetails(for: id) {
                                self.favRestaurants.append(restaurant)
                                print(restaurant.name)
                            }
                        }
                        DispatchQueue.main.async {
                            self.activityIndicator.isHidden = true
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backButtonTapped))
        closeButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.title = "Favorite Restaurants"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.reloadData()
        
        let backButton = UIBarButtonItem()
        backButton.title = "Favorite Restaurants"
        backButton.tintColor = .white
        navigationItem.backBarButtonItem = backButton
    }
    
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favRestaurants.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favRestCell", for: indexPath)
        let restaurant = favRestaurants[indexPath.row]
        
        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = restaurant.name
        }
        if let categoryLabel = cell.viewWithTag(2) as? UILabel{
            categoryLabel.text = restaurant.categories.joined(separator: " | ")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        selectedRest = favRestaurants[indexPath.row]
        performSegue(withIdentifier: "toRestaurant", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toRestaurant" {
            let destVC = segue.destination as! RestaurantDetailVC
            destVC.selectedRestaurant = selectedRest
        }
    }
    
}






class MyReservationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var reservations: [Reservation] = []
    var selectedReservation: Reservation!
    var selectedRestaurantDetail: Restaurant!
    
    override func viewWillAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            self.activityIndicatorView.isHidden = false
            self.fetchReservationsUser(for: user.uid) { reservations in
                if let reservations = reservations{
                    self.reservations = reservations
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }else{
            print("no user")
        }
        self.activityIndicatorView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backButtonTapped))
        closeButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.title = "My Reservations"
        
    }
    
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell", for: indexPath)
        let reservation = reservations[indexPath.row]
        
        let editButton = UIButton(type: .custom)
        editButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        editButton.tintColor = .gray
        editButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        editButton.addTarget(self, action: #selector(accessoryButtonTapped), for: .touchUpInside)
        editButton.tag = indexPath.row //to identify button
        cell.accessoryView = editButton
        
        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = reservation.restaurantName
        }
        if let dateLabel = cell.viewWithTag(2) as? UILabel {
            dateLabel.text = "\(reservation.date)\n\(reservation.time)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    @objc func accessoryButtonTapped(_ sender: UIButton){
        let resIndex = sender.tag
        selectedReservation = reservations[resIndex]
        Task {
            selectedRestaurantDetail = await fetchRestaurantDetails(for: selectedReservation.restaurantId)
            performSegue(withIdentifier: "toEditing", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditing" {
            let destVC = segue.destination as? EditResevationVC
            destVC?.reservation = self.selectedReservation
            destVC?.restaurantDetail = selectedRestaurantDetail
        }
    }
    


}
