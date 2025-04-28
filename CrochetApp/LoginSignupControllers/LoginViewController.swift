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


        try? Auth.auth().signOut()
    }
    
    func setupPasswordToggle() {
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordToggleButton.tintColor = .systemGray3
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
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
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = "Please enter both email and password."
            errorLabel.isHidden = false
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.isHidden = false
            } else {
                guard let user = firebaseResult?.user else {
                    self.errorLabel.text = "Login failed. Please try again."
                    self.errorLabel.isHidden = false
                    print("Login failed: No user returned and no error given.")
                    return
                }

                print("Logged in as: \(user.email ?? "Unknown")")
                self.errorLabel.isHidden = true
                self.performSegue(withIdentifier: "goToNext", sender: self)
            }

        }
    }
}
