import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CreateUsernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    @IBOutlet weak var yearsExperienceTextField: UITextField!
    @IBOutlet weak var numberOfProjectsTextField: UITextField!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!

    var userId: String?
    var name: String?
    var email: String?
    var selectedProfileImage: UIImage?
    var isUsernameAvailable: Bool = false {
        didSet {
            updateCreateButtonState()
        }
    }
    var hasCompletedAccountCreation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldDidChange), for: .editingChanged)

        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.clipsToBounds = true

        createAccountButton.isEnabled = false
        createAccountButton.alpha = 0.5
    }

    deinit {
        if !hasCompletedAccountCreation {
            cleanUpIncompleteUser()
        }
    }

    private func updateCreateButtonState() {
        createAccountButton.isEnabled = isUsernameAvailable
        createAccountButton.alpha = isUsernameAvailable ? 1.0 : 0.5
    }

    // MARK: - Username Availability Check

    @objc func usernameTextFieldDidChange(_ textField: UITextField) {
        guard let username = textField.text, !username.isEmpty else {
            usernameStatusLabel.text = ""
            isUsernameAvailable = false
            return
        }

        let db = Firestore.firestore()
        db.collection("userInformation")
            .whereField("userName", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking username: \(error.localizedDescription)")
                    self.usernameStatusLabel.text = "Error checking username"
                    self.usernameStatusLabel.textColor = .gray
                    self.isUsernameAvailable = false
                    return
                }

                if let count = snapshot?.documents.count, count > 0 {
                    self.usernameStatusLabel.text = "🚫 Username is taken"
                    self.usernameStatusLabel.textColor = .red
                    self.isUsernameAvailable = false
                } else {
                    self.usernameStatusLabel.text = "✅ Username is available"
                    self.usernameStatusLabel.textColor = .systemGreen
                    self.isUsernameAvailable = true
                }
            }
    }

    // MARK: - Profile Picture Selection

    @IBAction func profilePictureButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            selectedProfileImage = image
            profilePictureButton.setImage(image, for: .normal)
        }
    }

    // MARK: - Create Account Button

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        guard let userId = Auth.auth().currentUser?.uid,
              let name = name,
              let email = email,
              let username = usernameTextField.text, !username.isEmpty,
              let yearsText = yearsExperienceTextField.text, let numYears = Int(yearsText),
              let projectsText = numberOfProjectsTextField.text, let numProjects = Int(projectsText) else {
            showAlert(title: "Missing Information", message: "Please fill in all required fields.")
            return
        }

        guard isUsernameAvailable else {
            showAlert(title: "Username Taken", message: "Please choose a different username.")
            return
        }

        // Disable button to prevent double-taps
        createAccountButton.isEnabled = false
        createAccountButton.alpha = 0.5

        let db = Firestore.firestore()

        // Loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Saving your account...\n\n", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingAlert.view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -20)
        ])

        loadingIndicator.startAnimating()
        present(loadingAlert, animated: true, completion: nil)

        if let profileImage = selectedProfileImage,
           let imageData = profileImage.jpegData(compressionQuality: 0.4) {

            let storageRef = Storage.storage().reference().child("profile_pictures/\(userId).jpg")
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.dismiss(animated: true) {
                        self.showAlert(title: "Image Upload Error", message: error.localizedDescription)
                    }
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        self.dismiss(animated: true) {
                            self.showAlert(title: "Image URL Error", message: error.localizedDescription)
                        }
                        return
                    }

                    let pfpURL = url?.absoluteString ?? ""
                    self.saveUserData(db: db, userId: userId, name: name, email: email, username: username, numYears: numYears, numProjects: numProjects, pfpURL: pfpURL, loadingAlert: loadingAlert)
                }
            }

        } else {
            self.saveUserData(db: db, userId: userId, name: name, email: email, username: username, numYears: numYears, numProjects: numProjects, pfpURL: "", loadingAlert: loadingAlert)
        }
    }

    // MARK: - Save User Data

    private func saveUserData(db: Firestore, userId: String, name: String, email: String, username: String, numYears: Int, numProjects: Int, pfpURL: String, loadingAlert: UIAlertController) {
        let userData: [String: Any] = [
            "uid": userId,
            "userName": username,
            "email": email,
            "name": name,
            "numYearsCrochet": numYears,
            "numberOfProjects": numProjects,
            "pfpURL": pfpURL,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        db.collection("userInformation").document(userId).setData(userData, merge: true) { error in
            self.dismiss(animated: true) {
                if let error = error {
                    self.showAlert(title: "Save Error", message: error.localizedDescription)
                } else {
                    self.hasCompletedAccountCreation = true
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
            }
        }
    }

    // MARK: - Cleanup Abandoned User

    private func cleanUpIncompleteUser() {
        guard let user = Auth.auth().currentUser else { return }

        let userId = user.uid
        let db = Firestore.firestore()

        // Delete Firestore document
        db.collection("userInformation").document(userId).delete { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
            } else {
                print("User data deleted successfully.")
            }
        }

        // Delete Auth user
        user.delete { error in
            if let error = error {
                print("Error deleting Auth user: \(error.localizedDescription)")
            } else {
                print("Auth user deleted successfully.")
            }
        }
    }

    // MARK: - Alert Helper

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
