//
//  PersistenceController.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 14/2/24.
//

import CoreData
import Foundation

struct PersistenceController {
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoinControlModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Couldn't create persistence container: \(error.localizedDescription).")
            }

            CCLogger.debug("Created persistence container with description: \(description).")
        }
    }

    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                CCLogger.error("Can't save context: \(error)")
            }
        }
    }
}
