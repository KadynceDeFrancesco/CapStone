//
//  PatternCell.swift
//  CrochetApp
//
//  Created by Kadynce DeFrancesco on 2/18/25.
//

import Foundation
import UIKit

class PatternCell: UICollectionViewCell {
    
    @IBOutlet weak var fileTypeIcon: UIImageView!
    @IBOutlet weak var patternLabel: UILabel!

    func configure(with pattern: PatternFile) {
        patternLabel.text = pattern.name
        fileTypeIcon.image = UIImage(systemName: pattern.fileType == "pdf" ? "doc.text" : "photo")
    }
}
