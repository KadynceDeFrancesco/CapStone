//
//  CreateAccountViewController.swift
//  CrochetApp
//
//

import UIKit
import FirebaseAuth

class CreateUsernameViewController: UIViewController {


        
    @IBOutlet weak var UsernameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveUsernameClicked(_ sender: UIButton) {
        guard let username = UsernameTextField.text, !username.isEmpty,
              let user = Auth.auth().currentUser else {
            showAlert(message: "Please enter a username.")
            return
        }
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    }

