//
//  RevisionOfTranslation+CoreDataProperties.swift
//  
//
//  Created by 이건준 on 2023/08/22.
//
//

import Foundation
import CoreData


extension RevisionOfTranslation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RevisionOfTranslation> {
        return NSFetchRequest<RevisionOfTranslation>(entityName: "RevisionOfTranslation")
    }

    @NSManaged public var bibleName: String
    @NSManaged public var chapter: Int64
    @NSManaged public var jeol: Int64
    @NSManaged public var id: Int64

}
