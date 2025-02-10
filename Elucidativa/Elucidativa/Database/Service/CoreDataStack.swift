//
//  ExamCoreDataService.swift
//  Elucidativa
//
//  Created by Vitor Costa on 10/02/25.
//

import Foundation
import CoreData

let dbName = "ElucidativaCoreData"

class CoreDataStack {
    var persistentContainer: NSPersistentContainer
    static let shared = CoreDataStack()
    
    ///This should be private, but is public for tests
    init() {
        persistentContainer = NSPersistentContainer(name: dbName)
        persistentContainer.loadPersistentStores {(_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
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
}
