import UIKit
import SwiftUI

class DictionaryViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var holdStackView: UIStackView!
    
    @IBOutlet weak var singleCrochet: UIButton!
    @IBOutlet weak var doubleCrochet: UIButton!
    @IBOutlet weak var trebleCrochet: UIButton!
    @IBOutlet weak var halfdoubleCrochet: UIButton!
    
    @IBOutlet weak var singleCrochetDetails: UIStackView!
    @IBOutlet weak var doubleCrochetDetails: UIStackView!
    @IBOutlet weak var trebleCrochetDetails: UIStackView!
    @IBOutlet weak var halfDoubleCrochetDetails: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleCrochetDetails.isHidden = true
        doubleCrochetDetails.isHidden = true
        trebleCrochetDetails.isHidden = true
        halfDoubleCrochetDetails.isHidden = true
    }
    
    @IBAction func toggleDropdown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            switch sender {
            case self.singleCrochet:
                self.singleCrochetDetails.isHidden.toggle()
            case self.doubleCrochet:
                self.doubleCrochetDetails.isHidden.toggle()
            case self.trebleCrochet:
                self.trebleCrochetDetails.isHidden.toggle()
            case self.halfdoubleCrochet:
                self.halfDoubleCrochetDetails.isHidden.toggle()
            default:
                break
            }
        }
    }
}

