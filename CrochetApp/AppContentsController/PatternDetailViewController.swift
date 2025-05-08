//Shows and edits the details of a selected pattern, including instructions and progress.
//Displays a thumbnail (PDF or image), editable name, and step-by-step rows parsed from a PDF.
//Allows row-level tracking with progress updates.
//Includes image picker to update the cover image and PDF viewer launching capability.
import UIKit
import CoreData
import PDFKit

class PatternDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var pattern: PatternFile?
    var patternLines: [String] = []
    var crossedOutRows: Set<Int> = []

    @IBOutlet weak var patternNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var pdfImage: UIImageView!
    @IBOutlet weak var openFileButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        patternNameTextField.addTarget(self, action: #selector(nameFieldDidChange), for: .editingChanged)

        saveButton.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LineCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary

        pdfImage.layer.cornerRadius = 16
        pdfImage.layer.masksToBounds = true
        pdfImage.clipsToBounds = true
        pdfImage.contentMode = .scaleAspectFill
    
        
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.pdfImage)
            self.view.bringSubviewToFront(self.openFileButton)
            self.view.bringSubviewToFront(self.saveButton)
        }

        displayPattern()
    }



    func displayPattern() {
        if let savedRows = pattern?.crossedOutRows as? [Int] {
            crossedOutRows = Set(savedRows)
        }

        guard let pattern = pattern else {
            print("❌ No pattern passed in")
            return
        }

        patternNameTextField.text = pattern.name

        if let customImageData = pattern.customImage,
           let customImage = UIImage(data: customImageData) {
            pdfImage.image = customImage
        } else if pattern.fileType == "pdf", let fileData = pattern.fileData {
            pdfImage.image = getPDFThumbnail(data: fileData)
        } else {
            pdfImage.image = UIImage(systemName: "doc.fill")
        }

        guard pattern.fileType == "pdf", let fileData = pattern.fileData else {
            print("❌ Not a PDF or missing file data.")
            return
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(pattern.name ?? "file").pdf")

        do {
            try fileData.write(to: tempURL)
            if let document = PDFDocument(url: tempURL) {
                var allLines: [String] = []
                for i in 0..<document.pageCount {
                    if let page = document.page(at: i),
                       let pageText = page.string {
                        let lines = pageText.components(separatedBy: .newlines)
                        allLines.append(contentsOf: lines)
                    }
                }
                patternLines = extractPatternLines(from: allLines)

                DispatchQueue.main.async {
                    self.updateProgress()
                    self.tableView.reloadData()
                }
            } else {
                print("❌ Failed to create PDFDocument from URL")
            }
        } catch {
            print("❌ Failed to write PDF to tempURL: \(error.localizedDescription)")
        }
    }

    func extractPatternLines(from allLines: [String]) -> [String] {
        return allLines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.lowercased().hasPrefix("rnd") ||
                   trimmed.lowercased().hasPrefix("row") ||
                   trimmed.lowercased().hasPrefix("rounds") ||
                   trimmed.lowercased().hasPrefix("round")
        }
    }

    func updateProgress() {
        let total = patternLines.count
        let completed = crossedOutRows.count
        let percent = total > 0 ? Int(Double(completed) / Double(total) * 100) : 0
        progressLabel.text = "Progress: \(percent)% (\(completed)/\(total))"

        pattern?.progress = Int32(percent)
        pattern?.crossedOutRows = Array(crossedOutRows) as NSObject as? NSArray

        saveChanges()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patternLines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath)
        let line = patternLines[indexPath.row]

        var attributes: [NSAttributedString.Key: Any] = [:]
        if crossedOutRows.contains(indexPath.row) {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            attributes[.foregroundColor] = UIColor.gray
        }

        cell.textLabel?.attributedText = NSAttributedString(string: line, attributes: attributes)
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if crossedOutRows.contains(indexPath.row) {
            crossedOutRows.remove(indexPath.row)
        } else {
            crossedOutRows.insert(indexPath.row)
        }
        updateProgress()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    private func getPDFThumbnail(data: Data) -> UIImage? {
        guard let pdfDocument = PDFDocument(data: data),
              let page = pdfDocument.page(at: 0) else {
            return UIImage(systemName: "exclamationmark.triangle")
        }

        let targetSize = CGSize(width: 200, height: 280)
        let pageRect = page.bounds(for: .mediaBox)

        let scale = min(targetSize.width / pageRect.width, targetSize.height / pageRect.height)
        let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)

        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: scaledSize))

            let cgContext = context.cgContext
            cgContext.saveGState()
            cgContext.translateBy(x: 0, y: scaledSize.height)
            cgContext.scaleBy(x: 1.0, y: -1.0)
            cgContext.scaleBy(x: scale, y: scale)
            page.draw(with: .mediaBox, to: cgContext)
            cgContext.restoreGState()
        }
    }

    func saveChanges() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        do {
            try context.save()
            print("✅ Pattern updated successfully!")
        } catch {
            print("❌ Failed to save updated pattern: \(error.localizedDescription)")
        }
    }

    @IBAction func saveNameTapped(_ sender: UIButton) {

        view.endEditing(true)

        guard let updatedName = patternNameTextField.text, !updatedName.isEmpty else { return }
        pattern?.name = updatedName
        saveChanges()
        saveButton.isHidden = true
    }


    @IBAction func changeImageTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            handleSelectedImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            handleSelectedImage(originalImage)
        }

        picker.dismiss(animated: true)
    }

    func handleSelectedImage(_ image: UIImage) {
        let resized = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
        pdfImage.image = resized

        if let imageData = resized.jpegData(compressionQuality: 0.8) {
            pattern?.customImage = imageData
            saveChanges()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveChanges()
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    @objc func nameFieldDidChange() {
        guard let updatedName = patternNameTextField.text, !updatedName.isEmpty else {
            saveButton.isHidden = true
            return
        }

        if updatedName != pattern?.name {
            saveButton.isHidden = false
        } else {
            saveButton.isHidden = true
        }

        pattern?.name = updatedName
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
