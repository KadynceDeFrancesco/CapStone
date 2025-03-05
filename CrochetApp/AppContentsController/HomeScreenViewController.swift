import UIKit

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
    

}
