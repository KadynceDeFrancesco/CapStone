import UIKit
import CoreData

class PatternDetailViewController: UIViewController {
    
    var pattern: PatternFile?

    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var filePreview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPattern()
    }

    func displayPattern() {
        guard let pattern = pattern else { return }
        patternLabel.text = pattern.name
        
        if pattern.fileType == "pdf" {
            filePreview.image = UIImage(systemName: "doc.text") // Placeholder for PDFs
        } else if let fileData = pattern.fileData, let image = UIImage(data: fileData) {
            filePreview.image = image // Show stored image
        }
    }
    
    @IBAction func openPatternFile(_ sender: UIButton) {
        guard let pattern = pattern, let fileData = pattern.fileData else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(pattern.name ?? "file").\(pattern.fileType ?? "pdf")")
        do {
            try fileData.write(to: tempURL)
            let documentController = UIDocumentInteractionController(url: tempURL)
            documentController.presentPreview(animated: true)
        } catch {
            print("❌ Failed to open file: \(error.localizedDescription)")
        }
    }
}
