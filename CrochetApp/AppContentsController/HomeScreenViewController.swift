import UIKit

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var crochetDictionaryButton: UIButton!
    @IBOutlet weak var patternLibraryButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var userInformationtextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patternLibraryButton.isHighlighted = false
        patternLibraryButton.isSelected = false

        crochetDictionaryButton.isHighlighted = false
        crochetDictionaryButton.isSelected = false

        iconButton.isHighlighted = false
        iconButton.isSelected = false
        
    }

    
    
    @IBAction func PatternLibraryClicked(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToNext", sender: self)

    }
    
    @IBAction func CrochetButtonClicked(_ sender: UIButton) {
        
    }
    

}
