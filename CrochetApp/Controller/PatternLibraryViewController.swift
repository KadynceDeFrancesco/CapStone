import UIKit
import CoreData
import UniformTypeIdentifiers

class PatternLibraryViewController: UIViewController, UICollectionViewDataSource, UIDocumentPickerDelegate {

    @IBOutlet weak var PatternCells: UICollectionView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var patterns: [PatternFile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PatternCells.dataSource = self
        fetchPatterns()
    }
    
    // Fetch saved patterns from Core Data
    func fetchPatterns() {
        let request: NSFetchRequest<PatternFile> = PatternFile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            patterns = try context.fetch(request)
            DispatchQueue.main.async {
                self.PatternCells.reloadData()
            }
        } catch {
            print("❌ Failed to fetch patterns: \(error.localizedDescription)")
        }
    }

    // Open file picker for user to upload patterns
    @IBAction func addPatternTapped(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    // Handle selected file
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        savePattern(fileURL: selectedURL)
    }

    // Save uploaded file to Core Data
    func savePattern(fileURL: URL) {
        do {
            let fileData = try Data(contentsOf: fileURL)
            let newPattern = PatternFile(context: context)
            newPattern.id = UUID()
            newPattern.name = fileURL.lastPathComponent
            newPattern.fileData = fileData
            newPattern.fileType = fileURL.pathExtension
            newPattern.dateAdded = Date()
            
            try context.save()
            fetchPatterns()
        } catch {
            print("❌ Error saving pattern: \(error.localizedDescription)")
        }
    }

    // UICollectionView Data Source Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patterns.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatternCell", for: indexPath) as! PatternCell
        let pattern = patterns[indexPath.row]
        cell.configure(with: pattern)
        return cell
    }
}
