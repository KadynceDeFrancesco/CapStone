import UIKit
import PDFKit

class PatternCell: UICollectionViewCell {
    @IBOutlet weak var patternImageButton: UIButton!
    @IBOutlet weak var patternNameLabel: UILabel!

    var onViewTapped: (() -> Void)?

    @IBAction func imageButtonTapped(_ sender: UIButton) {
        print("📸 Pattern image tapped")
        onViewTapped?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        patternImageButton.imageView?.contentMode = .scaleAspectFit
        patternImageButton.contentHorizontalAlignment = .fill
        patternImageButton.contentVerticalAlignment = .fill

        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.layer.borderWidth = 4
        contentView.layer.borderColor = UIColor(red: 0.584, green: 0.396, blue: 0.706, alpha: 1).cgColor


        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }


    func configure(with pattern: PatternFile, onViewTapped: @escaping () -> Void) {
        
        self.onViewTapped = onViewTapped
        
        patternImageButton.imageView?.contentMode = .scaleAspectFit

        let cleanName = pattern.name?.replacingOccurrences(of: ".pdf", with: "") ?? "Unknown Pattern"
        patternNameLabel.text = cleanName
        patternNameLabel.textAlignment = .center
        patternNameLabel.numberOfLines = 2

        if let customImageData = pattern.customImage, let customImage = UIImage(data: customImageData) {
            // 🟢 Show custom image if it exists
            patternImageButton.setImage(customImage, for: .normal)
        } else if let data = pattern.fileData, pattern.fileType == "pdf" {
            // 🟡 Otherwise generate PDF thumbnail
            patternImageButton.setImage(getPDFThumbnail(data: data), for: .normal)
        } else {
            // 🔴 Fallback icon
            patternImageButton.setImage(UIImage(systemName: "doc.fill"), for: .normal)
        }
    }

    private func getPDFThumbnail(data: Data) -> UIImage? {
        guard let pdfDocument = PDFDocument(data: data),
              let page = pdfDocument.page(at: 0) else {
            return UIImage(systemName: "exclamationmark.triangle")
        }

        let targetSize = CGSize(width: 200, height: 280) // or any size you want for thumbnails
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

}

