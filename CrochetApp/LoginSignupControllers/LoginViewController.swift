//
//  LoginViewController.swift
//  CrochetApp
//
//  Created by Kadynce DeFrancesco on 2/17/25.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    let passwordToggleButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPasswordToggle()
        errorLabel.isHidden = true
    }
    
    func setupPasswordToggle() {

        passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        
        passwordToggleButton.tintColor = .systemGray3
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Set button inside text field
        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
    }

    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let iconName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    @IBAction func LoginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if error != nil{
                print("error")
            }
            else{
                //Go to the home screen
                self.performSegue(withIdentifier: "goToNext", sender: self)
                
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
