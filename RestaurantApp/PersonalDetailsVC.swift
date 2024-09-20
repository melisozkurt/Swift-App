//
//  PersonalDetailsVC.swift
//  MyProject
//
//  Created by MELİS on 20.08.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PersonalDetailsVC: UIViewController {

    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var surnameTxtField: UITextField!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var guestsTxtField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var confirmButton: UIButton!
    
    var nameLabel = UILabel()
    var surnameLabel = UILabel()
    var phoneLabel = UILabel()
    
    var reservation: Reservation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guestsTxtField.isUserInteractionEnabled = false
        guestsTxtField.text = String(Int(stepper.value))

        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .gray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        surnameLabel.text = "Surname"
        surnameLabel.font = UIFont.systemFont(ofSize: 12)
        surnameLabel.textColor = .gray
        surnameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        phoneLabel.text = "Phone Number"
        phoneLabel.font = UIFont.systemFont(ofSize: 12)
        phoneLabel.textColor = .gray
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
                
        self.view.addSubview(nameLabel)
        self.view.addSubview(surnameLabel)
        self.view.addSubview(phoneLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: nameTxtField.leadingAnchor, constant: 1),
            nameLabel.bottomAnchor.constraint(equalTo: nameTxtField.topAnchor, constant: -3)
                ])
        NSLayoutConstraint.activate([
            surnameLabel.leadingAnchor.constraint(equalTo: surnameTxtField.leadingAnchor, constant: 1),
            surnameLabel.bottomAnchor.constraint(equalTo: surnameTxtField.topAnchor, constant: -3)
                ])
        NSLayoutConstraint.activate([
            phoneLabel.leadingAnchor.constraint(equalTo: phoneTxtField.leadingAnchor, constant: 1),
            phoneLabel.bottomAnchor.constraint(equalTo: phoneTxtField.topAnchor, constant: -3)
                ])
        
        if let user = Auth.auth().currentUser{
            let userRef = db.collection("users").document(user.uid)
            userRef.getDocument { document, error in
                if let error = error {
                    print("error: document: \(error.localizedDescription)")
                }
                if let document = document, document.exists{
                    if let name = document.get("name") as? String {
                        self.nameTxtField.text = name
                    }
                    if let surname = document.get("surname") as? String{
                        self.surnameTxtField.text = surname
                    }
                }else{
                    print("no document")
                }
            }
        }
        else {
            print("no user found")
        }
    }
    

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        guestsTxtField.text = String(Int(sender.value))
    }

    
    @IBAction func confirmTapped(_ sender: UIButton) {
        
        confirmButton.configuration?.showsActivityIndicator = true
        reservation.name = nameTxtField.text!
        reservation.surname = surnameTxtField.text!
        reservation.phone = phoneTxtField.text!
        reservation.numberOfGuests = Int(guestsTxtField.text!)!
        
        sendReservation(reservation) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showAlert(title: "Table Reserved", message: "Your table is waiting for you.", error: false)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.showAlert(title: "Warning!", message: "Error: The table could not be reserved.", error: true)                }
            }
            self.confirmButton.configuration?.showsActivityIndicator = false
        }
    }
    

    func showAlert(title: String, message: String, error: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if error {
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okButton)
        }else{
            let okAction = UIAlertAction(title: "OK", style: .default) {_ in
                if let viewControllers = self.navigationController?.viewControllers {
                    for vc in viewControllers {
                        if vc.restorationIdentifier == "restaurantDetailsVC" {
                            self.navigationController?.popToViewController(vc, animated: true)
                            return
                        }
                    }
                }
            }
            alert.addAction(okAction)
        }
        
        self.present(alert, animated: true, completion: nil)
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
