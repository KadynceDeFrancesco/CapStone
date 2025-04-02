import UIKit
import FirebaseAuth

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var crochetDictionaryButton: UIButton!
    @IBOutlet weak var patternLibraryButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var userInformationtextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
