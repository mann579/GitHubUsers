//
//  DatabaseManager.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation
import CoreData

enum DatabaseRequestError: Error {
    case fetchUsers(offset:Int, message: String)
    
    private var errorCode: Int {
        switch self {
        case .fetchUsers(_, _): return 200
        }
    }
    
    var description: String {
        switch self {
        case .fetchUsers(let offset, let message):
            return "Fetch users from offset=\(offset) :: \(message)"
        }
    }
}

enum DatabaseRequestResult<T> {
    case success(T)
    case failure(DatabaseRequestError)
}

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    var readContext: NSManagedObjectContext = Reference.appDelegate.persistentContainer.viewContext
    lazy var writeContext: NSManagedObjectContext = {
        let newbackgroundContext = Reference.appDelegate.persistentContainer.newBackgroundContext()
        newbackgroundContext.automaticallyMergesChangesFromParent = true
        return newbackgroundContext
    }()
    
    init() {
        if let dbDescription = Reference.appDelegate.persistentContainer.persistentStoreDescriptions.first,
           let path = dbDescription.url {
            print("Local database path: \(path)")
        }
    }
    
    // MARK: - Managed User for Writing
    
    public func userCreateOrUpdate(from codableModel: User) {
        guard let primaryKey = codableModel.id else { return }

        self.writeContext.performAndWait({
            let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "UserCD")
            fetchRequest.predicate = NSPredicate(format: "id = %d", primaryKey)
            
            var items: [Any] = []
            do {
                items = try self.writeContext.fetch(fetchRequest)
            }
            catch let error {
                print("Fetch error for id=\(primaryKey) :: \(error.localizedDescription)")
            }

            let entity = NSEntityDescription.entity(forEntityName: "UserCD", in: self.writeContext)
            
            // create
            if items.count == 0 {
                let newUser = NSManagedObject(entity: entity!, insertInto: self.writeContext)
                newUser.setValue(codableModel.id, forKey: "id")
                newUser.setValue(codableModel.login, forKey: "login")
                newUser.setValue(codableModel.avatarUrl, forKey: "avatarUrl")
                newUser.setValue(codableModel.reposUrl, forKey: "reposUrl")

                do {
                    try self.writeContext.save()
                }
                catch let error {
                    print("Failed create user for \(codableModel.login ?? "") (\(codableModel.id ?? 0)) :: \(error.localizedDescription)")
                }
            }
            // update
            else {
                if let objectToUpdate = items.first as? NSManagedObject {
                    objectToUpdate.setValue(codableModel.id, forKey: "id")
                    objectToUpdate.setValue(codableModel.login, forKey: "login")
                    objectToUpdate.setValue(codableModel.avatarUrl, forKey: "avatarUrl")
                    objectToUpdate.setValue(codableModel.reposUrl, forKey: "reposUrl")
                    
                    do {
                        try self.writeContext.save()
                    }
                    catch let error {
                        print("Failed update user for \(codableModel.login ?? "") (\(codableModel.id ?? 0)) :: \(error.localizedDescription)")
                    }
                }
            }
        })
    }

    
    // MARK: - Managed User for Reading
        
    public func getUsers(
        offset: Int,
        limit: Int,
        completion: @escaping (DatabaseRequestResult<[NSManagedObject]?>) -> ()) {
        
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "UserCD")
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = offset
        
        var items: [Any] = []
        do {
            items = try self.readContext.fetch(fetchRequest)
            completion(DatabaseRequestResult.success(items as? [NSManagedObject]))
        }
        catch let error {
            completion(DatabaseRequestResult.failure(.fetchUsers(offset: offset, message: error.localizedDescription)))
        }
    }
    
    public func getUserById(userId: Int32) -> NSManagedObject? {
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "UserCD")
        fetchRequest.predicate = NSPredicate(format: "id = %d", userId)
        
        var items: [Any] = []
        do {
            items = try self.readContext.fetch(fetchRequest)
        }
        catch let error {
            print("Fetch error for id=\(userId) :: \(error.localizedDescription)")
            return nil
        }
        
        if items.count == 1 {
            if let user = items.first as? NSManagedObject {
                return user
            }
        }
        return nil
    }
    
    public func getUsersByIds(userIds: [Int32]) -> [NSManagedObject]? {
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "UserCD")
        fetchRequest.predicate = NSPredicate(format: "id in %@", userIds)
        
        var items: [Any] = []
        do {
            items = try self.readContext.fetch(fetchRequest)
            return items as? [NSManagedObject]
        }
        catch let error {
            print("Fetch error for ids=\(userIds) :: \(error.localizedDescription)")
            return nil
        }
    }
}
