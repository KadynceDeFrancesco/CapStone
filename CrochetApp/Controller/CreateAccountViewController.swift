//
//  CreateAccountViewController.swift
//  CrochetApp
//
//

import UIKit
import Firebase
import FirebaseAuth

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func CreateAnAccountClicked(_ sender: UIButton) {
        
        guard let email = EmailTextField.text else{return}
        guard let password = PasswordTextField.text else{return}
        
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let e = error{
                print("error")
            }
            else{
                //Go to the home screen
                self.performSegue(withIdentifier: "goToNext", sender: self)
                
            }
        }
        
    }
    

}
