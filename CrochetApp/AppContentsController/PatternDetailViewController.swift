import UIKit
import CoreData
import PDFKit

class PatternDetailViewController: UIViewController {
    
    var pattern: PatternFile?

    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var filePreview: UIImageView!
    @IBOutlet weak var pdfView: PDFView! // Make sure this is hooked up in storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPattern()
    }

    func displayPattern() {
        guard let pattern = pattern else { return }
        patternLabel.text = pattern.name
        
        if pattern.fileType == "pdf", let fileData = pattern.fileData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(pattern.name ?? "file").pdf")
            do {
                try fileData.write(to: tempURL)
                let document = PDFDocument(url: tempURL)
                pdfView.document = document
                pdfView.autoScales = true
                filePreview.isHidden = true
            } catch {
                print("❌ Failed to load PDF: \(error.localizedDescription)")
            }
        } else if let fileData = pattern.fileData, let image = UIImage(data: fileData) {
            filePreview.image = image
            pdfView.isHidden = true
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
