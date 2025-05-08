//Displays the authenticated user's dashboard with access to profile and navigation.
//Loads user info from Firestore and profile image from Firebase Storage.
//Displays a grid of work-in-progress (WIP) patterns from Core Data.
//Includes logout functionality and profile picture update via image picker.
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import CoreData

class HomeScreenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var crochetDictionaryButton: UIButton!
    @IBOutlet weak var patternLibraryButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var userInformationLabel: UILabel!
    @IBOutlet weak var wipCollectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var projectsLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!

    var wipPatterns: [PatternFile] = []
    var selectedPattern: PatternFile?

    override func viewDidLoad() {
        super.viewDidLoad()

        yearsLabel.layer.cornerRadius = 12
        yearsLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        yearsLabel.layer.masksToBounds = true

        userInformationLabel.layer.cornerRadius = 12
        userInformationLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        userInformationLabel.layer.masksToBounds = true

        fetchUserData()

        wipCollectionView.delegate = self
        wipCollectionView.dataSource = self
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        fetchWIPPatterns()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Fetch CoreData Patterns
    private func fetchWIPPatterns() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<PatternFile> = PatternFile.fetchRequest()
        request.predicate = NSPredicate(format: "progress > 0")
        request.sortDescriptors = [NSSortDescriptor(key: "progress", ascending: false)]

        do {
            let inProgressPatterns = try context.fetch(request)
            self.wipPatterns = inProgressPatterns
            self.wipCollectionView.reloadData()
        } catch {
            print("❌ Failed to fetch in-progress patterns: \(error)")
        }
    }

    // MARK: - Fetch User Data
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

            self.userInformationLabel.text = data["userName"] as? String ?? "No username"
            self.nameLabel.text = data["name"] as? String ?? "No name"

            if let numProjects = data["numberOfProjects"] as? Int {
                self.projectsLabel.text = "Projects: \(numProjects)"
            } else {
                self.projectsLabel.text = "Projects: N/A"
            }

            if let numYears = data["numYearsCrochet"] as? Int {
                self.yearsLabel.text = "Years: \(numYears)"
            } else {
                self.yearsLabel.text = "Years: N/A"
            }

            if let pfpURLString = data["pfpURL"] as? String,
               let pfpURL = URL(string: pfpURLString),
               !pfpURLString.isEmpty {
                self.iconButton.sd_setImage(with: pfpURL, for: .normal, completed: nil)
            } else {
                self.iconButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
            }
        }
    }

    // MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wipPatterns.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WIPCell", for: indexPath) as? WIPCell else {
            return UICollectionViewCell()
        }

        let pattern = wipPatterns[indexPath.item]
        cell.configure(with: pattern, onViewTapped: { [weak self] in
            guard let self = self else { return }
            self.selectedPattern = pattern
            self.performSegue(withIdentifier: "goToPatternDetail", sender: self)
        })

        return cell
    }

    // MARK: - Layout: Proper spacing and padding

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 16
        let itemsPerRow: CGFloat = 3
        let totalSpacing = spacing * (itemsPerRow + 1)
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width + 20) // height slightly more than width
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPatternDetail" {
            guard let destination = segue.destination as? PatternDetailViewController else { return }
            if let patternToSend = selectedPattern {
                destination.pattern = patternToSend
            } else {
                print("❌ No selected pattern to pass to detail view!")
            }
        }
    }

    // MARK: - Button Actions
    @IBAction func iconButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = info[.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.4),
              let userId = Auth.auth().currentUser?.uid else {
            print("Image selection failed")
            return
        }

        let storageRef = Storage.storage().reference().child("profile_pictures/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }

                guard let downloadURL = url else { return }

                let db = Firestore.firestore()
                db.collection("userInformation").document(userId).updateData([
                    "pfpURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("Firestore update error: \(error.localizedDescription)")
                    } else {
                        print("Profile picture URL updated")
                        self.iconButton.sd_setImage(with: downloadURL, for: .normal, completed: nil)
                    }
                }
            }
        }
    }

    @IBAction func patternLibraryButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPatternLibrary", sender: self)
    }

    @IBAction func crochetDictionaryButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCrochetDictionary", sender: self)
    }

    @IBAction func logOut(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let scene = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                   let sceneDelegate = scene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window,
                   let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {

                    // ✅ Embed in navigation controller
                    let navController = UINavigationController(rootViewController: loginVC)

                    window.rootViewController = navController
                    window.makeKeyAndVisible()

                    UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: nil)
                }

            } catch let error {
                print("❌ Failed to sign out: \(error.localizedDescription)")
            }
        }))

        present(alert, animated: true, completion: nil)
    }

}
