import UIKit
import PDFKit

class PatternCell: UICollectionViewCell {
    @IBOutlet weak var patternImageView: UIImageView!
    @IBOutlet weak var patternNameLabel: UILabel!
    

    func configure(with pattern: PatternFile) {
        guard let patternNameLabel = patternNameLabel else {
            print("❌ patternNameLabel is nil!")
            return
        }

        // ✅ Remove ".pdf" extension from the name
        let cleanName = pattern.name?.replacingOccurrences(of: ".pdf", with: "") ?? "Unknown Pattern"
        patternNameLabel.text = cleanName

        // ✅ Extract PDF thumbnail or use default image
        if let data = pattern.fileData, pattern.fileType == "pdf" {
            print("🛠 Extracting PDF thumbnail for: \(cleanName)")
            patternImageView.image = getPDFThumbnail(data: data)
        } else {
            print("❌ No valid file found, using default icon")
            patternImageView.image = UIImage(systemName: "doc.fill")
        }
    }

    /// Extracts the first page of a PDF as an image
    private func getPDFThumbnail(data: Data) -> UIImage? {
        guard let pdfDocument = PDFDocument(data: data),
              let page = pdfDocument.page(at: 0) else {
            print("❌ Failed to load PDF")
            return UIImage(systemName: "exclamationmark.triangle") // Error icon
        }

        let pdfPageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pdfPageRect.size)

        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(pdfPageRect)
            page.draw(with: .mediaBox, to: context.cgContext)
        }

        return image
    }
    
    
}
