//UICollectionViewCell used in the Pattern Library view.
//Displays pattern preview and name.
//Supports delete mode with a red minus button and wiggle animation.
//Dynamically generates thumbnails from PDFs or displays uploaded images.
import UIKit
import PDFKit
import AVFoundation

class PatternCell: UICollectionViewCell {
    @IBOutlet weak var patternImageButton: UIButton!
    @IBOutlet weak var patternNameLabel: UILabel!
    
    var onViewTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?

    
    private let deleteButton = UIButton(type: .custom)
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        print("📸 Pattern image tapped")
        onViewTapped?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.clipsToBounds = false
        self.clipsToBounds = false

        var config = UIButton.Configuration.plain()
        config.imagePadding = 0
        config.contentInsets = .zero
        config.imagePlacement = .top
        patternImageButton.configuration = config

        patternImageButton.contentHorizontalAlignment = .center
        patternImageButton.contentVerticalAlignment = .top


        patternImageButton.imageView?.contentMode = .scaleAspectFit
        patternImageButton.configuration?.imagePlacement = .top
        patternImageButton.contentHorizontalAlignment = .center
        patternImageButton.contentVerticalAlignment = .center

        setupDeleteButton()
    }

    
    private func setupDeleteButton() {
        deleteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.isHidden = true
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }

    
    func configure(with pattern: PatternFile, onViewTapped: @escaping () -> Void, onDeleteTapped: (() -> Void)? = nil) {
        self.onViewTapped = onViewTapped
        self.onDeleteTapped = onDeleteTapped
        
        patternImageButton.imageView?.contentMode = .scaleAspectFit
        
        let cleanName = pattern.name?.replacingOccurrences(of: ".pdf", with: "") ?? "Unknown Pattern"
        patternNameLabel.text = cleanName
        patternNameLabel.textAlignment = .center
        patternNameLabel.numberOfLines = 1

        var displayImage: UIImage?
        
        if let customImageData = pattern.customImage, let customImage = UIImage(data: customImageData) {
            displayImage = customImage
        } else if let data = pattern.fileData, pattern.fileType == "pdf" {
            displayImage = getPDFThumbnail(data: data)
        } else {
            displayImage = UIImage(systemName: "doc.fill")
        }
        
        if let image = displayImage {
            let resized = resizeForButton(image: image)
            patternImageButton.setImage(resized, for: .normal)

            DispatchQueue.main.async {
                if let imageView = self.patternImageButton.imageView {
                    imageView.layer.borderWidth = 4
                    imageView.layer.cornerRadius = 12
                    imageView.layer.masksToBounds = true
                    imageView.layer.borderColor = UIColor(red: 0.584, green: 0.396, blue: 0.706, alpha: 1).cgColor
                }
            }
        }

        patternNameLabel.text = cleanName



    }
    
    private func resizeForButton(image: UIImage) -> UIImage {
        let buttonSize = CGSize(width: 110, height: 150)
        let aspectFitRect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: buttonSize))

        let renderer = UIGraphicsImageRenderer(size: buttonSize)
        return renderer.image { _ in
            UIColor.clear.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: buttonSize)).fill()
            image.draw(in: aspectFitRect)
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
    
    func setDeleteMode(_ enabled: Bool) {
        deleteButton.isHidden = !enabled
        if enabled {
            startWiggle()
        } else {
            stopWiggle()
        }
    }
    
    private func startWiggle() {
        let angle = 0.04
        let wiggle = CAKeyframeAnimation(keyPath: "transform.rotation")
        wiggle.values = [-angle, angle]
        wiggle.autoreverses = true
        wiggle.duration = 0.15
        wiggle.repeatCount = .infinity
        layer.add(wiggle, forKey: "wiggle")
    }
    
    private func stopWiggle() {
        layer.removeAnimation(forKey: "wiggle")
    }
}
