import UIKit
import CoreData
import UniformTypeIdentifiers
import PDFKit

class PatternLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView! 
    @IBOutlet weak var datecreatedFiltering: UICommand!
    @IBOutlet weak var lastopenedFiltering: UICommand!
    @IBOutlet weak var zaFiltering: UICommand!
    @IBOutlet weak var azFiltering: UICommand!

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var patterns: [PatternFile] = []
    var filteredPatterns: [PatternFile] = []
    var isFiltering = false
    var isInDeleteMode = false


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
    
    @IBAction func deleteModeButtonTapped(_ sender: UIBarButtonItem) {
        isInDeleteMode.toggle()
        collectionView.reloadData()

        if isInDeleteMode {
            sender.title = "Done"
        } else {
            sender.title = "Delete"
        }
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isFiltering = false
            filteredPatterns = patterns
        } else {
            isFiltering = true
            filteredPatterns = patterns.filter { $0.name?.lowercased().contains(searchText.lowercased()) ?? false }
        }
        collectionView.reloadData() // Ensure you reload the correct view
    }
    
    // MARK: - Handle Pattern Selection for Deletion
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isInDeleteMode {
            let selectedPattern = patterns[indexPath.row]
            confirmDeletion(for: selectedPattern)
        }
    }

    // MARK: - Confirm Deletion with Alert
    func confirmDeletion(for pattern: PatternFile) {
        let alert = UIAlertController(
            title: "Delete Pattern",
            message: "Are you sure you want to delete \"\(pattern.name ?? "Unnamed")\"?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deletePattern(pattern)
        }))
        
        present(alert, animated: true)
    }

    // MARK: - Delete Pattern from Core Data
    func deletePattern(_ pattern: PatternFile) {
        context.delete(pattern)
        do {
            try context.save()
            fetchPatterns() // Refresh UI
        } catch {
            print("❌ Failed to delete pattern: \(error)")
        }
    }



    
    func sortPatterns(by option: String) {
        switch option {
        case "dateCreated":
            patterns.sort { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() }
        case "A-Z":
            patterns.sort { ($0.name ?? "").lowercased() < ($1.name ?? "").lowercased() }
        case "Z-A":
            patterns.sort { ($0.name ?? "").lowercased() > ($1.name ?? "").lowercased() }
        default:
            break
        }

        collectionView.reloadData()
    }

}
