//
//  CustomSearch.swift
//  CustomSearch
//
//  Created by Brotecs Mac Mini on 12/15/21.
//

import Foundation

class CustomSearch: Decodable {
//    var queries: Queries?
    var searchInformation: SearchInformation?
    var items: [Items]?
}

//class Queries: Decodable {
//    var previousPage: [PreviousPage]?
//    var nextPage: [NextPage]?
//}

class SearchInformation: Decodable {
    var formattedSearchTime: String?
    var formattedTotalResults: String?
}

class Items: Decodable {
    var title: String?
    var link: String?
    var snippet: String?
}

//class NextPage: Decodable {
//    var title: String?
//    var totalResults: String?
//    var searchTerms: String?
//    var count: Int = 0
//    var startIndex: Int = 1
//    var inputEncoding: String?
//    var outputEncoding: String?
//    var safe: String?
//    var cx: String?
//}

//class PreviousPage: Decodable {
//    var title: String?
//    var totalResults: String?
//    var searchTerms: String?
//    var count: Int = 0
//    var startIndex: Int = 1
//    var inputEncoding: String?
//    var outputEncoding: String?
//    var safe: String?
//    var cx: String?
//}






//
//  CustomSearch+CoreDataClass.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//enum DecoderConfigurationError: Error {
//    case missingManagedObjectContext
//}
//
//@objc(CustomSearch)
//public class CustomSearch: NSManagedObject, Decodable {
//
//    enum CodingKeys: CodingKey {
//        case items, queries
//    }
//
//    public required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.items = try container.decode([Items].self, forKey: .items)
//        self.queries = try container.decode(Queries.self, forKey: .queries)
//        self.items = try container.decodeIfPresent([Items].self, forKey: .items)
//        self.queries = try container.decodeIfPresent(Queries.self, forKey: .queries)
//    }
//}
//
//extension CodingUserInfoKey {
//    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
//}



//
//  CustomSearch+CoreDataProperties.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//
//extension CustomSearch {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomSearch> {
//        return NSFetchRequest<CustomSearch>(entityName: "CustomSearch")
//    }
//
//    @NSManaged public var items: [Items]?
//    @NSManaged public var queries: Queries?
//    @NSManaged public var searchQuery: String?
//    @NSManaged public var itemsRelation: NSSet?
//    @NSManaged public var queriesRelation: NSSet?
//
//}
//
//// MARK: Generated accessors for itemsRelation
//extension CustomSearch {
//
//    @objc(addItemsRelationObject:)
//    @NSManaged public func addToItemsRelation(_ value: Items)
//
//    @objc(removeItemsRelationObject:)
//    @NSManaged public func removeFromItemsRelation(_ value: Items)
//
//    @objc(addItemsRelation:)
//    @NSManaged public func addToItemsRelation(_ values: NSSet)
//
//    @objc(removeItemsRelation:)
//    @NSManaged public func removeFromItemsRelation(_ values: NSSet)
//
//}
//
//// MARK: Generated accessors for queriesRelation
//extension CustomSearch {
//
//    @objc(addQueriesRelationObject:)
//    @NSManaged public func addToQueriesRelation(_ value: Queries)
//
//    @objc(removeQueriesRelationObject:)
//    @NSManaged public func removeFromQueriesRelation(_ value: Queries)
//
//    @objc(addQueriesRelation:)
//    @NSManaged public func addToQueriesRelation(_ values: NSSet)
//
//    @objc(removeQueriesRelation:)
//    @NSManaged public func removeFromQueriesRelation(_ values: NSSet)
//
//}



//
//  Items+CoreDataClass.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//@objc(Items)
//public class Items: NSManagedObject, Decodable {
//
//    enum CodingKeys: CodingKey {
//        case link, title, snippet
//    }
//
//    public required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        self.link = try container.decode(String.self, forKey: .link)
////        self.title = try container.decode(String.self, forKey: .title)
////        self.snippet = try container.decode(String.self, forKey: .snippet)
//        self.link = try container.decodeIfPresent(String.self, forKey: .link)
//        self.title = try container.decodeIfPresent(String.self, forKey: .title)
//        self.snippet = try container.decodeIfPresent(String.self, forKey: .snippet)
//    }
//
//}



//
//  Items+CoreDataProperties.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//
//extension Items {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Items> {
//        return NSFetchRequest<Items>(entityName: "Items")
//    }
//
//    @NSManaged public var link: String?
//    @NSManaged public var snippet: String?
//    @NSManaged public var title: String?
//
//}



//
//  Queries+CoreDataClass.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//@objc(Queries)
//public class Queries: NSManagedObject, Decodable {
//
//    enum CodingKeys: CodingKey {
//        case previousPage, nextPage
//    }
//
//    public required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        self.previousPage = try container.decode([PreviousPage].self, forKey: .previousPage)
////        self.nextPage = try container.decode([NextPage].self, forKey: .nextPage)
//        self.previousPage = try container.decodeIfPresent([PreviousPage].self, forKey: .previousPage)
//        self.nextPage = try container.decodeIfPresent([NextPage].self, forKey: .nextPage)
//    }
//
//}



//
//  Queries+CoreDataProperties.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//
//extension Queries {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Queries> {
//        return NSFetchRequest<Queries>(entityName: "Queries")
//    }
//
//    @NSManaged public var nextPage: [NextPage]?
//    @NSManaged public var previousPage: [PreviousPage]?
//    @NSManaged public var nextPageRelation: NSSet?
//    @NSManaged public var previousPageRelation: NSSet?
//
//}
//
//// MARK: Generated accessors for nextPageRelation
//extension Queries {
//
//    @objc(addNextPageRelationObject:)
//    @NSManaged public func addToNextPageRelation(_ value: NextPage)
//
//    @objc(removeNextPageRelationObject:)
//    @NSManaged public func removeFromNextPageRelation(_ value: NextPage)
//
//    @objc(addNextPageRelation:)
//    @NSManaged public func addToNextPageRelation(_ values: NSSet)
//
//    @objc(removeNextPageRelation:)
//    @NSManaged public func removeFromNextPageRelation(_ values: NSSet)
//
//}
//
//// MARK: Generated accessors for previousPageRelation
//extension Queries {
//
//    @objc(addPreviousPageRelationObject:)
//    @NSManaged public func addToPreviousPageRelation(_ value: PreviousPage)
//
//    @objc(removePreviousPageRelationObject:)
//    @NSManaged public func removeFromPreviousPageRelation(_ value: PreviousPage)
//
//    @objc(addPreviousPageRelation:)
//    @NSManaged public func addToPreviousPageRelation(_ values: NSSet)
//
//    @objc(removePreviousPageRelation:)
//    @NSManaged public func removeFromPreviousPageRelation(_ values: NSSet)
//
//}



//
//  PreviousPage+CoreDataClass.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//@objc(PreviousPage)
//public class PreviousPage: NSManagedObject, Decodable {
//
//    enum CodingKeys: CodingKey {
//        case startIndex
//    }
//
//    public required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        self.startIndex = try container.decode(Int64.self, forKey: .startIndex)
//        self.startIndex = try container.decodeIfPresent(Int64.self, forKey: .startIndex) ?? 1
//    }
//
//}



//
//  PreviousPage+CoreDataProperties.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//
//extension PreviousPage {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreviousPage> {
//        return NSFetchRequest<PreviousPage>(entityName: "PreviousPage")
//    }
//
//    @NSManaged public var startIndex: Int64
//    @NSManaged public var queriesRelation: Queries?
//
//}



//
//  NextPage+CoreDataClass.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//@objc(NextPage)
//public class NextPage: NSManagedObject, Decodable {
//
//    enum CodingKeys: CodingKey {
//        case startIndex
//    }
//
//    public required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        self.startIndex = try container.decode(Int64.self, forKey: .startIndex)
//        self.startIndex = try container.decodeIfPresent(Int64.self, forKey: .startIndex) ?? 1
//    }
//
//}



//
//  NextPage+CoreDataProperties.swift
//  Demo
//
//  Created by Brotecs Mac Mini on 1/10/22.
//
//

//import Foundation
//import CoreData
//
//
//extension NextPage {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<NextPage> {
//        return NSFetchRequest<NextPage>(entityName: "NextPage")
//    }
//
//    @NSManaged public var startIndex: Int64
//    @NSManaged public var queriesRelation: Queries?
//
//}
