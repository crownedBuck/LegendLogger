//
//  Characters+CoreDataProperties.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 5/15/24.
//
//

import Foundation
import CoreData


extension Characters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Characters> {
        return NSFetchRequest<Characters>(entityName: "Characters")
    }

    @NSManaged public var characterColorR: Float
    @NSManaged public var characterLocationX: Float
    @NSManaged public var characterName: String?
    @NSManaged public var characterSize: Float
    @NSManaged public var characterLocationY: Float
    @NSManaged public var characterColorG: Float
    @NSManaged public var characterColorB: Float
    @NSManaged public var characterColorA: Float
    @NSManaged public var maps: Maps?

    public var colorR: Float {
        characterColorR
    }
    
    public var locationX: Float {
        characterLocationX
    }
    
    public var name: String {
        characterName ?? "Billy Bob"
    }
    
    public var size: Float {
        characterSize
    }
    
    public var locationY: Float {
        characterLocationY
    }
    
    public var colorG: Float {
        characterColorG
    }
    
    public var colorB: Float {
        characterColorB
    }
    
    public var colorA: Float {
        characterColorA
    }
    
}

extension Characters : Identifiable {

}
