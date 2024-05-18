//
//  Persistence.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 4/30/24.
//
import CoreData
import UIKit

class Persistence {
    // Singleton instance
    static let shared = Persistence()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SwiftUILegandLogger")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addPhoto(photo: UIImage, name: String) -> Maps {
        let context = persistentContainer.viewContext
        let newMap = Maps(context: context)
        let date = Date()
        
        newMap.mapImage = photo.pngData()
        newMap.date = date
        newMap.mapName = name
        newMap.id = UUID() // Assign a new UUID
        
        saveContext() // Save context after adding photo
        return newMap
    }
    
    func fetchMaps() -> [Maps] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Maps> = Maps.fetchRequest()
        
        do {
            let mapsArray = try context.fetch(request)
            return mapsArray
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            return []
        }
    }
    
    func fetchMap(by id: UUID) -> Maps? {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Maps> = Maps.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let mapsArray = try context.fetch(request)
            return mapsArray.first
        } catch {
            let nserror = error as NSError
            print("Failed to fetch map by id: \(nserror)")
            return nil
        }
    }
    
    func deleteMap(map: Maps) {
        let context = persistentContainer.viewContext
        context.delete(map)
        saveContext() // Save context after deleting map
    }
    
    func editMapName(id: NSManagedObjectID, newTitle: String) {
        let context = persistentContainer.viewContext

        do {
            let mapToUpdate = try context.existingObject(with: id) as? Maps
            if let map = mapToUpdate {
                if map.isFault {
                    context.refresh(map, mergeChanges: true)
                }
                map.mapName = newTitle
                saveContext() // Save context after editing map name
                print("Map successfully saved.")
            } else {
                print("No map found with the given ID.")
            }
        } catch {
            print("Failed to fetch or save map name: \(error)")
        }
    }

    func saveCharacter(context: NSManagedObjectContext, positionX: Float, positionY: Float, colorA: Float, colorR: Float, colorG: Float, colorB: Float, size: Float, id: UUID) -> Characters? {
        guard let map = fetchMap(by: id) else { return nil }
        let character = Characters(context: context)
        character.characterLocationX = positionX
        character.characterLocationY = positionY
        character.characterColorA = colorA
        character.characterColorR = colorR
        character.characterColorG = colorG
        character.characterColorB = colorB
        character.characterSize = size
        map.addToCharacters(character)
        saveContext() // Save context after saving character
        print("Character saved for map with id \(id)")
        return character
    }

    func fetchCharacters(for map: Maps) -> [Characters] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Characters> = Characters.fetchRequest()
        request.predicate = NSPredicate(format: "maps == %@", map)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch characters: \(error)")
            return []
        }
    }

    func updateCharacter(character: Characters, newPosition: CGPoint, newSize: CGFloat) {
        let context = persistentContainer.viewContext
        character.characterLocationX = Float(newPosition.x)
        character.characterLocationY = Float(newPosition.y)
        character.characterSize = Float(newSize)
        
        saveContext() // Save context after updating character
        print("Character updated with position: \(newPosition) and size: \(newSize)")
    }
}
