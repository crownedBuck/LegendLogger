//
//  Maps+CoreDataProperties.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 5/15/24.
//
//

import Foundation
import CoreData


extension Maps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Maps> {
        return NSFetchRequest<Maps>(entityName: "Maps")
    }

    @NSManaged public var date: Date?
    @NSManaged public var mapImage: Data?
    @NSManaged public var mapName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var characters: NSSet?

    public var theDate: Date {
        date ?? Date()
    }
    
    public var image: Data {
        mapImage ?? Data()
    }
    
    public var name: String {
        mapName ?? "My Map"
    }
    
    public var characterArray: [Characters] {
        let set = characters as? Set<Characters> ?? []
        
        return Array(set)
    }
}

// MARK: Generated accessors for characters
extension Maps {

    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Characters)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Characters)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: NSSet)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: NSSet)

}

extension Maps : Identifiable {

}
