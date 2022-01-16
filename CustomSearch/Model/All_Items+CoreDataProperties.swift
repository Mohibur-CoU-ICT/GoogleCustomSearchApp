//
//  All_Items+CoreDataProperties.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/13/22.
//
//

import Foundation
import CoreData


extension All_Items {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<All_Items> {
        return NSFetchRequest<All_Items>(entityName: "All_Items")
    }

    @NSManaged public var link: String?
    @NSManaged public var searchQuery: String?
    @NSManaged public var snippet: String?
    @NSManaged public var title: String?
    @NSManaged public var pageContent: String?

}
