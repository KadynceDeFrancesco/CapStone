import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var passwordRulesLabel: UILabel!
    @IBOutlet weak var emailStatusLabel: UILabel!
    @IBOutlet weak var phoneStatusLabel: UILabel!

    var userId: String?

    var isEmailAvailable = false { didSet { updateCreateAccountButtonState() } }
    var isPhoneAvailable = false { didSet { updateCreateAccountButtonState() } }
    var isPasswordValid = false { didSet { updateCreateAccountButtonState() } }
    var areFieldsFilled = false { didSet { updateCreateAccountButtonState() } }

    override func viewDidLoad() {
        super.viewDidLoad()

        createAccountButton.isEnabled = false
        createAccountButton.alpha = 0.5

        errorMessageLabel.text = ""
        errorMessageLabel.numberOfLines = 0
        passwordRulesLabel.text = "Password must be at least 6 characters,\nuppercase, lowercase, number, and special character."
        passwordRulesLabel.numberOfLines = 0

        emailStatusLabel.text = ""
        phoneStatusLabel.text = ""

        EmailTextField.delegate = self
        PhoneTextField.delegate = self
        PasswordTextField.delegate = self
        ConfirmPasswordTextField.delegate = self
        NameTextField.delegate = self

        PasswordTextField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
        ConfirmPasswordTextField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
        NameTextField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == EmailTextField {
            checkEmailAvailability()
        } else if textField == PhoneTextField {
            checkPhoneAvailability()
        } else {
            validateFields()
        }
    }

    @objc func validateFields() {
        let nameFilled = !(NameTextField.text?.isEmpty ?? true)
        let emailFilled = !(EmailTextField.text?.isEmpty ?? true)
        let phoneFilled = !(PhoneTextField.text?.isEmpty ?? true)
        let password = PasswordTextField.text ?? ""
        let confirmPassword = ConfirmPasswordTextField.text ?? ""

        func isStrongPassword(_ password: String) -> Bool {
            let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^a-zA-Z0-9]).{6,}$")
            return passwordTest.evaluate(with: password)
        }

        if password.isEmpty || confirmPassword.isEmpty {
            isPasswordValid = false
            errorMessageLabel.text = "Please enter your password and confirm it."
        } else if password != confirmPassword {
            isPasswordValid = false
            errorMessageLabel.text = "Passwords do not match."
        } else if !isStrongPassword(password) {
            isPasswordValid = false
            errorMessageLabel.text = "Password must have uppercase, lowercase, number, special character, and 6+ characters."
        } else {
            isPasswordValid = true
            errorMessageLabel.text = ""
        }

        areFieldsFilled = nameFilled && emailFilled && phoneFilled
    }

    private func updateCreateAccountButtonState() {
        let allValid = isEmailAvailable && isPhoneAvailable && isPasswordValid && areFieldsFilled
        createAccountButton.isEnabled = allValid
        createAccountButton.alpha = allValid ? 1.0 : 0.5
    }

    private func checkEmailAvailability() {
        guard let email = EmailTextField.text, !email.isEmpty else {
            isEmailAvailable = false
            emailStatusLabel.text = ""
            return
        }

        let db = Firestore.firestore()
        db.collection("userInformation").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if snapshot?.documents.count ?? 0 > 0 {
                self.emailStatusLabel.text = "🚫 Email already in use."
                self.emailStatusLabel.textColor = .red
                self.isEmailAvailable = false
            } else {
                self.emailStatusLabel.text = "✅ Email is available."
                self.emailStatusLabel.textColor = .systemGreen
                self.isEmailAvailable = true
            }
        }
    }

    private func checkPhoneAvailability() {
        guard let phone = PhoneTextField.text, !phone.isEmpty else {
            isPhoneAvailable = false
            phoneStatusLabel.text = ""
            return
        }

        let db = Firestore.firestore()
        db.collection("userInformation").whereField("phoneNumber", isEqualTo: phone).getDocuments { snapshot, error in
            if snapshot?.documents.count ?? 0 > 0 {
                self.phoneStatusLabel.text = "🚫 Phone already in use."
                self.phoneStatusLabel.textColor = .red
                self.isPhoneAvailable = false
            } else {
                self.phoneStatusLabel.text = "✅ Phone number is available."
                self.phoneStatusLabel.textColor = .systemGreen
                self.isPhoneAvailable = true
            }
        }
    }

    @IBAction func CreateAnAccountClicked(_ sender: UIButton) {
        guard let email = EmailTextField.text,
              let password = PasswordTextField.text,
              let name = NameTextField.text,
              let phone = PhoneTextField.text else {
            errorMessageLabel.text = "🚫 Please fill in all fields."
            return
        }

        if !isPasswordValid || !areFieldsFilled {
            errorMessageLabel.text = "🚫 Please ensure all fields are valid."
            return
        }

        let db = Firestore.firestore()
        db.collection("userInformation").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if snapshot?.documents.count ?? 0 > 0 {
                self.errorMessageLabel.text = "🚫 An account with this email already exists."
                self.isEmailAvailable = false
                self.updateCreateAccountButtonState()
                return
            }

            db.collection("userInformation").whereField("phoneNumber", isEqualTo: phone).getDocuments { snapshot, error in
                if snapshot?.documents.count ?? 0 > 0 {
                    self.errorMessageLabel.text = "🚫 An account with this phone number already exists."
                    self.isPhoneAvailable = false
                    self.updateCreateAccountButtonState()
                    return
                }

                self.AuthCreateUser(email: email, password: password, name: name, phone: phone)
            }
        }
    }

    private func AuthCreateUser(email: String, password: String, name: String, phone: String) {
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                self.errorMessageLabel.text = "🚫 Error creating user: \(error.localizedDescription)"
            } else if let user = firebaseResult?.user {
                self.userId = user.uid
                print("✅ Created Auth user with UID: \(user.uid)")

                if self.userId == nil {
                    print("❌ ERROR: userId is nil after Auth creation!!")
                }

                self.saveInitialUserData(userId: user.uid, email: email, name: name, phone: phone)
            }
        }
    }


    private func saveInitialUserData(userId: String, email: String, name: String, phone: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": userId,
            "email": email,
            "name": name,
            "phoneNumber": phone,
            "createdAt": FieldValue.serverTimestamp(),
            "userName": "",
            "numYearsCrochet": 0,
            "numberOfProjects": 0,
            "pfpURL": ""
        ]

        db.collection("userInformation").document(userId).setData(userData) { error in
            if let error = error {
                print("❌ Failed to create Firestore document: \(error.localizedDescription)")
                self.errorMessageLabel.text = "🚫 Could not save user info."
                return
            }

            print("✅ Firestore document created for UID: \(userId)")

            if let userId = self.userId {
                print("✅ About to perform segue with userId: \(userId)")
                self.performSegue(withIdentifier: "goToNext", sender: userId)
            } else {
                print("❌ Cannot segue because userId is still nil!!")
            }

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNext" {
            if let destinationVC = segue.destination as? CreateUsernameViewController,
               let userId = sender as? String {
                print("✅ Passing userId to CreateUsernameViewController: \(userId)")
                destinationVC.userId = userId
            } else {
                print("❌ Could not cast sender as String in prepare(for segue:)")
            }
        }
    }
}
