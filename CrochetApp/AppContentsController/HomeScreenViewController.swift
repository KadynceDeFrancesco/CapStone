import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class HomeScreenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var videoLibraryButton: UIButton!
    @IBOutlet weak var crochetDictionaryButton: UIButton!
    @IBOutlet weak var patternLibraryButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var userInformationLabel: UILabel! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }


    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("userInformation").document(userId)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("User document does not exist")
                return
            }
            
            // Set username
            if let username = data["userName"] as? String {
                self.userInformationLabel.text = username
            } else {
                self.userInformationLabel.text = "No username"
            }
            
            // Set profile picture
            if let pfpURLString = data["pfpURL"] as? String,
               let pfpURL = URL(string: pfpURLString),
               !pfpURLString.isEmpty {
                self.iconButton.sd_setImage(with: pfpURL, for: .normal, completed: nil)
            } else {
                self.iconButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
            }
        }
    }
    
    @IBAction func iconButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.4),
              let userId = Auth.auth().currentUser?.uid else {
            print("Image selection failed")
            return
        }
        
        // Upload to Firebase Storage
        let storageRef = Storage.storage().reference().child("profile_pictures/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return
            }
            
            // Get download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url else { return }
                
                // Update Firestore user profile
                let db = Firestore.firestore()
                db.collection("userInformation").document(userId).updateData([
                    "pfpURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("Firestore update error: \(error.localizedDescription)")
                    } else {
                        print("Profile picture URL updated")
                        // Refresh profile picture
                        self.iconButton.sd_setImage(with: downloadURL, for: .normal, completed: nil)
                    }
                }
            }
        }
    }

    @IBAction func PatternLibraryClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNext", sender: self)
    }
    
    @IBAction func CrochetButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNext", sender: self)
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = loginVC
                window.makeKeyAndVisible()
            }
        } catch let signOutError {
            print("❌ Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
