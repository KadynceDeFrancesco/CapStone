import UIKit
import CoreData
import UniformTypeIdentifiers
import PDFKit

class PatternLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var collectionView: UICollectionView! // ✅ Only one UICollectionView reference

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var patterns: [PatternFile] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if collectionView == nil {
            print("❌ collectionView is nil!")
        } else {
            print("✅ collectionView is initialized!")
        }

        collectionView.dataSource = self
        collectionView.delegate = self

        fetchPatterns()
    }

    // ✅ Fetch saved patterns from Core Data
    func fetchPatterns() {
        let request: NSFetchRequest<PatternFile> = PatternFile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]

        do {
            patterns = try context.fetch(request)
            print("✅ Patterns Fetched: \(patterns.count) items")

            for pattern in patterns {
                let cleanName = pattern.name?.replacingOccurrences(of: ".pdf", with: "") ?? "Unknown"
                print("➡️ Pattern Name: \(cleanName), Type: \(pattern.fileType ?? "Unknown")")
            }

            // ✅ Reload collectionView safely
            DispatchQueue.main.async {
                if self.collectionView == nil {
                    print("❌ collectionView is nil!")
                } else {
                    print("✅ Reloading collectionView with \(self.patterns.count) items")
                    self.collectionView.reloadData()
                }
            }
        } catch {
            print("❌ Failed to fetch patterns: \(error.localizedDescription)")
        }
    }

    // ✅ Open Document Picker to Add Patterns
    @IBAction func addPatternTapped(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // ✅ Handle selected file from Document Picker
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        let patternName = selectedURL.deletingPathExtension().lastPathComponent // ✅ Remove ".pdf"
        savePattern(fileURL: selectedURL, patternName: patternName)
    }

    // ✅ Save uploaded file to Core Data
    func savePattern(fileURL: URL, patternName: String) {
        do {
            let fileData = try Data(contentsOf: fileURL)
            let newPattern = PatternFile(context: context)

            newPattern.id = UUID()
            newPattern.name = patternName // ✅ Already without ".pdf"
            newPattern.fileData = fileData
            newPattern.fileType = fileURL.pathExtension
            newPattern.dateAdded = Date()

            try context.save()
            
            print("✅ Saved Pattern: \(newPattern.name ?? "Unknown"), Type: \(newPattern.fileType ?? "Unknown")")
            
            fetchPatterns() // ✅ Reload collection view after saving
            
        } catch {
            print("❌ Error saving pattern: \(error.localizedDescription)")
        }
    }

    // ✅ UICollectionView Data Source Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patterns.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatternCell", for: indexPath) as? PatternCell else {
            fatalError("❌ Failed to dequeue PatternCell")
        }

        let pattern = patterns[indexPath.row]
        cell.configure(with: pattern)
        return cell
    }
}
