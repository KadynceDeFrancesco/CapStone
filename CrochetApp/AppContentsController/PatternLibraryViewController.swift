//Displays the complete library of saved crochet patterns.
//Loads patterns from Core Data and allows sorting and searching.
//Supports adding new patterns via a PDF document picker.
//Includes delete mode for removing patterns and navigates to the pattern detail screen.
import UIKit
import CoreData
import PDFKit
import UniformTypeIdentifiers

class PatternLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var patterns: [PatternFile] = []
    var filteredPatterns: [PatternFile] = []
    
    var isInDeleteMode = false
    var selectedPattern: PatternFile?
    
    var isFiltering: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        setupCollectionViewLayout()
        fetchPatterns()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPatterns()
        collectionView.reloadData()
    }



    // MARK: - Collection Layout
    func setupCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }


    // MARK: - Fetch CoreData
    func fetchPatterns() {
        let request: NSFetchRequest<PatternFile> = PatternFile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            patterns = try context.fetch(request)
            collectionView.reloadData()
        } catch {
            print("❌ Failed to fetch patterns: \(error.localizedDescription)")
        }
    }

    // MARK: - Document Picker
    @IBAction func addPatternTapped(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    // MARK: - Filter Button
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sort Patterns", message: "Choose a filter", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Newest First", style: .default, handler: { _ in
            self.sortPatterns(by: .newest)
        }))
        
        alert.addAction(UIAlertAction(title: "Oldest First", style: .default, handler: { _ in
            self.sortPatterns(by: .oldest)
        }))
        
        alert.addAction(UIAlertAction(title: "Name A–Z", style: .default, handler: { _ in
            self.sortPatterns(by: .nameAscending)
        }))
        
        alert.addAction(UIAlertAction(title: "Name Z–A", style: .default, handler: { _ in
            self.sortPatterns(by: .nameDescending)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    enum SortOption {
        case newest
        case oldest
        case nameAscending
        case nameDescending
    }

    func sortPatterns(by option: SortOption) {
        switch option {
        case .newest:
            patterns.sort { ($0.dateAdded ?? Date()) > ($1.dateAdded ?? Date()) }
        case .oldest:
            patterns.sort { ($0.dateAdded ?? Date()) < ($1.dateAdded ?? Date()) }
        case .nameAscending:
            patterns.sort { ($0.name ?? "") < ($1.name ?? "") }
        case .nameDescending:
            patterns.sort { ($0.name ?? "") > ($1.name ?? "") }
        }
        
        if isFiltering, let searchText = searchBar.text {
            filteredPatterns = patterns.filter {
                $0.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        
        collectionView.reloadData()
    }



    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        let patternName = selectedURL.deletingPathExtension().lastPathComponent
        savePattern(fileURL: selectedURL, patternName: patternName)
    }

    func savePattern(fileURL: URL, patternName: String) {
        do {
            let fileData = try Data(contentsOf: fileURL)
            let newPattern = PatternFile(context: context)
            newPattern.id = UUID()
            newPattern.name = patternName
            newPattern.fileData = fileData
            newPattern.fileType = fileURL.pathExtension
            newPattern.dateAdded = Date()

            try context.save()
            fetchPatterns()
        } catch {
            print("❌ Error saving pattern: \(error.localizedDescription)")
        }
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering ? filteredPatterns.count : patterns.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("🔎 Attempting to dequeue PatternCell")

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatternCell", for: indexPath) as? PatternCell else {
            fatalError("❌ Failed to dequeue PatternCell")
        }


        cell.setDeleteMode(isInDeleteMode)

        let pattern = isFiltering ? filteredPatterns[indexPath.row] : patterns[indexPath.row]

        cell.configure(
            with: pattern,
            onViewTapped: { [weak self] in
                print("🔁 Image tapped for: \(pattern.name ?? "Unnamed")")
                self?.selectedPattern = pattern
                self?.performSegue(withIdentifier: "goToNext", sender: self)
            },
            onDeleteTapped: { [weak self] in
                guard let self = self else { return }
                self.confirmDeletion(for: pattern)
            }
        )

        return cell
    }



    // MARK: - Dynamic Cell Sizing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let paddingSpace: CGFloat = 10 * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem + 30)
    }



    // MARK: - Search Filtering
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPatterns = []
        } else {
            filteredPatterns = patterns.filter {
                $0.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        collectionView.reloadData()
    }

    // MARK: - Delete Mode
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        isInDeleteMode.toggle()
        deleteButton.setTitle(isInDeleteMode ? "Cancel Delete" : "Delete", for: .normal)
        selectedPattern = nil
        collectionView.reloadData()
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = isFiltering ? filteredPatterns[indexPath.row] : patterns[indexPath.row]
        if isInDeleteMode {
            confirmDeletion(for: selected)
        } else {
            // This is unused now because image tap triggers segue
        }
    }

    func confirmDeletion(for pattern: PatternFile) {
        let alert = UIAlertController(title: "Delete Pattern", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.context.delete(pattern)
            do {
                try self.context.save()
                self.fetchPatterns()
            } catch {
                print("❌ Failed to delete pattern: \(error)")
            }
            self.isInDeleteMode = false
            self.deleteButton.setTitle("Delete", for: .normal)
        }))
        present(alert, animated: true)
    }
    

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNext",
           let destinationVC = segue.destination as? PatternDetailViewController,
           let patternToSend = selectedPattern {
            print("✅ Passing pattern: \(patternToSend.name ?? "Unnamed")")
            destinationVC.pattern = patternToSend
        } else {
            print("❌ Pattern not passed. Segue identifier or destination may be incorrect.")
        }
    }

}
