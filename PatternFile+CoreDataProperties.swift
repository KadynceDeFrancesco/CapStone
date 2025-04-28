//
//  PatternFile+CoreDataProperties.swift
//  CrochetApp
//
//  Created by Kadynce DeFrancesco on 4/27/25.
//
//

import Foundation
import CoreData


extension PatternFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PatternFile> {
        return NSFetchRequest<PatternFile>(entityName: "PatternFile")
    }

    @NSManaged public var dateAdded: Date?
    @NSManaged public var fileData: Data?
    @NSManaged public var fileType: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var customImage: Data?

}

extension PatternFile : Identifiable {

}
