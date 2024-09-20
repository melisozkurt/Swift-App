//
//  LoginViewController.swift
//  MyProject
//
//  Created by MELİS on 24.08.2024.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct User {
    var name: String
    var surname: String
    var mail: String
}

let db = Firestore.firestore()

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        backButton.tintColor = .black
        
        passTextField.isSecureTextEntry = true
        
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        if mailTextField.text != "" && passTextField.text! != "" {
            logInButton.configuration?.showsActivityIndicator = true
            Auth.auth().signIn(withEmail: mailTextField.text!, password: passTextField.text!) { authResult, error in
                if let error = error {
                    self.showError("Login error: \(error.localizedDescription)")
                    self.logInButton.configuration?.showsActivityIndicator = false
                }else{
                    self.performSegue(withIdentifier: "toHomeScreen", sender: nil)
                    self.logInButton.configuration?.showsActivityIndicator = false
                }
            }
        }
    }
    
    
    @IBAction func registerTapped(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }

    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}





class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var surnameTxtField: UITextField!
    @IBOutlet weak var passTxtField: UITextField!
    @IBOutlet weak var mailTxtField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    var nameLabel = UILabel()
    var surnameLabel = UILabel()
    var passLabel = UILabel()
    var mailLabel = UILabel()
    
    let grayColor = UIColor(red: 0.197, green: 0.197, blue: 0.197, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = UILabel()
        title.text = "REGISTER"
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = .black
        navigationItem.titleView = title
        
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = grayColor
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        surnameLabel.text = "Surname"
        surnameLabel.font = UIFont.systemFont(ofSize: 12)
        surnameLabel.textColor = grayColor
        surnameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        passLabel.text = "Password"
        passLabel.font = UIFont.systemFont(ofSize: 12)
        passLabel.textColor = grayColor
        passLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mailLabel.text = "E-mail"
        mailLabel.font = UIFont.systemFont(ofSize: 12)
        mailLabel.textColor = grayColor
        mailLabel.translatesAutoresizingMaskIntoConstraints = false
                
        self.view.addSubview(nameLabel)
        self.view.addSubview(surnameLabel)
        self.view.addSubview(passLabel)
        self.view.addSubview(mailLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: nameTxtField.leadingAnchor, constant: 1),
            nameLabel.bottomAnchor.constraint(equalTo: nameTxtField.topAnchor, constant: -3)
                ])
        NSLayoutConstraint.activate([
            surnameLabel.leadingAnchor.constraint(equalTo: surnameTxtField.leadingAnchor, constant: 1),
            surnameLabel.bottomAnchor.constraint(equalTo: surnameTxtField.topAnchor, constant: -3)
                ])
        NSLayoutConstraint.activate([
            passLabel.leadingAnchor.constraint(equalTo: passTxtField.leadingAnchor, constant: 1),
            passLabel.bottomAnchor.constraint(equalTo: passTxtField.topAnchor, constant: -3)
                ])
        NSLayoutConstraint.activate([
            mailLabel.leadingAnchor.constraint(equalTo: mailTxtField.leadingAnchor, constant: 1),
            mailLabel.bottomAnchor.constraint(equalTo: mailTxtField.topAnchor, constant: -3)
                ])

        passTxtField.isSecureTextEntry = true

    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        guard let name = nameTxtField.text, !name.isEmpty,
                 let surname = surnameTxtField.text, !surname.isEmpty,
                 let mail = mailTxtField.text, !mail.isEmpty,
                 let pass = passTxtField.text, !pass.isEmpty else {
               self.showError("Please fill in all fields.")
               return
           }

           Auth.auth().createUser(withEmail: mail, password: pass) { authResult, error in
               
               self.signUpButton.configuration?.showsActivityIndicator = true
               
               if let error = error {
                   self.showError("Failed to create user: \(error.localizedDescription)")
                   self.signUpButton.configuration?.showsActivityIndicator = false
                   return
               }

               if let user = authResult?.user {
                   let changeRequest = user.createProfileChangeRequest()
                   changeRequest.displayName = "\(name) \(surname)"
                   changeRequest.commitChanges { error in
                       if let error = error {
                           self.showError("Failed to set display name: \(error.localizedDescription)")
                           self.signUpButton.configuration?.showsActivityIndicator = false
                       } else {
                           db.collection("users").document(user.uid).setData([
                               "name": name,
                               "surname": surname,
                               "e-mail": mail,
                               "favorite restaurants": []
                           ]) { error in
                               if let error = error {
                                   self.showError("Failed to write user data: \(error.localizedDescription)")
                               } else {
                                   self.performSegue(withIdentifier: "toHomeScreen2", sender: nil)
                               }
                           }
                       }
                       self.signUpButton.configuration?.showsActivityIndicator = false
                   }
               }
           }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHomeScreen2" {
            if let navC = segue.destination as? UINavigationController {
                if let  destVC = navC.topViewController as? ViewController {
                    destVC.user = appUser
                }
            }
            
        }
    }*/
}

