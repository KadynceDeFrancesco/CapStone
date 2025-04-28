import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CreateUsernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    @IBOutlet weak var yearsExperienceTextField: UITextField!
    @IBOutlet weak var numberOfProjectsTextField: UITextField!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!

    // MARK: - Properties
    var userId: String?
    var selectedProfileImage: UIImage?

    var isUsernameAvailable = false {
        didSet { updateCreateButtonState() }
    }

    var hasCompletedAccountCreation = false

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("👀 userId when arriving at CreateUsernameViewController: \(userId ?? "nil")")

        if self.userId == nil {
            self.userId = Auth.auth().currentUser?.uid
            print("🔄 Pulled userId from Firebase Auth: \(userId ?? "nil")")
        }

        if let userId = self.userId {
            print("✅ userId available: \(userId)")
            if !hasCompletedAccountCreation {
                checkFirestoreDocumentExists()
            }
        } else {
            print("❌ STILL missing user ID.")
            showAlert(title: "Error", message: "Missing user ID.")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !hasCompletedAccountCreation && isMovingFromParent {
            cleanUpIncompleteUser()
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.clipsToBounds = true

        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldDidChange), for: .editingChanged)

        createAccountButton.isEnabled = false
        createAccountButton.alpha = 0.5
    }

    // MARK: - Firestore Safety Check
    private func checkFirestoreDocumentExists() {
        guard let userId = self.userId else {
            showAlert(title: "Error", message: "Missing user ID.")
            return
        }

        Firestore.firestore().collection("userInformation").document(userId).getDocument { doc, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Could not check user record: \(error.localizedDescription)")
            } else if doc?.exists == false {
                self.showAlert(title: "Account Error", message: "User record not found. Please restart registration.")
            }
        }
    }

    // MARK: - Username Availability
    @objc private func usernameTextFieldDidChange(_ textField: UITextField) {
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
                    self.usernameStatusLabel.text = "Error: \(error.localizedDescription)"
                    self.usernameStatusLabel.textColor = .gray
                    self.isUsernameAvailable = false
                    return
                }

                if snapshot?.documents.count ?? 0 > 0 {
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

    private func updateCreateButtonState() {
        createAccountButton.isEnabled = isUsernameAvailable
        createAccountButton.alpha = isUsernameAvailable ? 1.0 : 0.5
    }

    // MARK: - Profile Picture Selection
    @IBAction func profilePictureButtonTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            selectedProfileImage = image
            profilePictureButton.setImage(image, for: .normal)
        }
    }

    // MARK: - Create Final Account Info
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        guard let uid = self.userId,
              let username = usernameTextField.text, !username.isEmpty,
              let yearsText = yearsExperienceTextField.text, let numYears = Int(yearsText),
              let projectsText = numberOfProjectsTextField.text, let numProjects = Int(projectsText) else {
            showAlert(title: "Missing Info", message: "Fill all fields and upload your image.")
            return
        }

        createAccountButton.isEnabled = false
        createAccountButton.alpha = 0.5

        showLoadingAlert {
            if let image = self.selectedProfileImage,
               let data = image.jpegData(compressionQuality: 0.4) {
                self.uploadProfilePicture(uid: uid, data: data, username: username, numYears: numYears, numProjects: numProjects)
            } else {
                self.saveUserData(uid: uid, username: username, numYears: numYears, numProjects: numProjects, pfpURL: "")
            }
        }
    }

    private func uploadProfilePicture(uid: String, data: Data, username: String, numYears: Int, numProjects: Int) {
        let ref = Storage.storage().reference().child("profile_pictures/\(uid).jpg")
        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                self.dismiss(animated: true) {
                    self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                }
                return
            }

            ref.downloadURL { url, error in
                let pfpURL = url?.absoluteString ?? ""
                self.saveUserData(uid: uid, username: username, numYears: numYears, numProjects: numProjects, pfpURL: pfpURL)
            }
        }
    }

    private func saveUserData(uid: String, username: String, numYears: Int, numProjects: Int, pfpURL: String) {
        let db = Firestore.firestore()
        let updatedData: [String: Any] = [
            "userName": username,
            "numYearsCrochet": numYears,
            "numberOfProjects": numProjects,
            "pfpURL": pfpURL,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        db.collection("userInformation").document(uid).setData(updatedData, merge: true) { error in
            self.dismiss(animated: true) {
                if let error = error {
                    self.showAlert(title: "Error Saving", message: error.localizedDescription)
                } else {
                    self.hasCompletedAccountCreation = true
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
            }
        }
    }

    // MARK: - Cleanup on Cancel
    private func cleanUpIncompleteUser() {
        guard let uid = self.userId else { return }

        let db = Firestore.firestore()
        db.collection("userInformation").document(uid).delete { error in
            print(error == nil ? "Deleted Firestore user data." : "Firestore delete error: \(error!.localizedDescription)")
        }

        Auth.auth().currentUser?.delete { error in
            print(error == nil ? "Deleted Auth user." : "Auth delete error: \(error!.localizedDescription)")
        }
    }

    // MARK: - Helper UI Methods
    private func showLoadingAlert(completion: @escaping () -> Void) {
        let loadingAlert = UIAlertController(title: nil, message: "Creating your account...\n\n", preferredStyle: .alert)
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        loadingAlert.view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            spinner.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -20)
        ])
        spinner.startAnimating()
        present(loadingAlert, animated: true, completion: completion)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
