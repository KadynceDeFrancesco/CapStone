//UICollectionViewCell used on the Home screen to show work-in-progress patterns.
//Displays a tappable pattern icon with image, progress badge, and name label.
//Loads images from custom data or renders PDF thumbnail if no image provided.

import UIKit
import PDFKit
import AVFoundation

class WIPCell: UICollectionViewCell {

    @IBOutlet weak var patternImageButton: UIButton!
    @IBOutlet weak var patternNameLabel: UILabel!

    var onViewTapped: (() -> Void)?

    let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    @IBAction func imageButtonTapped(_ sender: UIButton) {
        onViewTapped?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        patternImageButton.layer.cornerRadius = 16
        patternImageButton.clipsToBounds = true
        patternImageButton.contentHorizontalAlignment = .fill
        patternImageButton.contentVerticalAlignment = .fill
        patternImageButton.imageView?.contentMode = .scaleToFill
        patternImageButton.imageView?.clipsToBounds = true

        patternImageButton.layer.borderWidth = 1.5
        patternImageButton.layer.borderColor = UIColor.systemGray4.cgColor
        patternImageButton.layer.shadowColor = UIColor.black.cgColor
        patternImageButton.layer.shadowOpacity = 0.2
        patternImageButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        patternImageButton.layer.shadowRadius = 4

        patternNameLabel.textAlignment = .center
        patternNameLabel.numberOfLines = 2
        patternNameLabel.adjustsFontSizeToFitWidth = true
        patternNameLabel.minimumScaleFactor = 0.7
        patternNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        contentView.addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            progressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            progressLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }


    func configure(with pattern: PatternFile, onViewTapped: @escaping () -> Void, onDeleteTapped: (() -> Void)? = nil) {
        self.onViewTapped = onViewTapped

        if pattern.progress > 0 {
            progressLabel.text = "\(pattern.progress)%"
            progressLabel.isHidden = false
        } else {
            progressLabel.isHidden = true
        }

        let cleanName = pattern.name?.replacingOccurrences(of: ".pdf", with: "") ?? "Unknown Pattern"
        patternNameLabel.text = cleanName

        var displayImage: UIImage?

        if let customImageData = pattern.customImage, let customImage = UIImage(data: customImageData) {
            displayImage = customImage
        } else if let data = pattern.fileData, pattern.fileType == "pdf" {
            displayImage = getPDFThumbnail(data: data)
        } else {
            displayImage = UIImage(systemName: "doc.fill")
        }

        if let image = displayImage {
            patternImageButton.setImage(image, for: .normal)
        }

    }

    private func resizeForButton(image: UIImage) -> UIImage {
        let buttonSize = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: buttonSize)

        return renderer.image { _ in
            UIColor.clear.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: buttonSize)).fill()

            let aspectRatio = image.size.width / image.size.height
            var drawRect = CGRect.zero

            if aspectRatio > 1 {
                let height = buttonSize.width / aspectRatio
                drawRect = CGRect(x: 0, y: (buttonSize.height - height)/2, width: buttonSize.width, height: height)
            } else {
                let width = buttonSize.height * aspectRatio
                drawRect = CGRect(x: (buttonSize.width - width)/2, y: 0, width: width, height: buttonSize.height)
            }

            image.draw(in: drawRect)
        }
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
}
