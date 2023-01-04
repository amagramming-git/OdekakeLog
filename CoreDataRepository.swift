//
//  CoreDataRepository.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/04.
//
import CoreData

class CoreDataRepository {

    init() {}

    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "OdekakeLog")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private static var context: NSManagedObjectContext {
        return CoreDataRepository.persistentContainer.viewContext
    }
}

// MARK: for Create
extension CoreDataRepository {
    static func entity<T: NSManagedObject>() -> T {
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context)!
        return T(entity: entityDescription, insertInto: nil)
    }
}

// MARK: CRUD
extension CoreDataRepository {
    static func array<T: NSManagedObject>(predicate:String = "",sortKey:String = "",ascending:Bool = true) -> [T] {
        do {
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            if !predicate.isEmpty {
                request.predicate = NSPredicate(format: predicate)
            }
            if !sortKey.isEmpty {
                request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: ascending)]
            }
            return try context.fetch(request)
        } catch {
            fatalError()
        }
    }

    static func add(_ object: NSManagedObject) {
        context.insert(object)
    }

    static func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
}

// MARK: context CRUD
extension CoreDataRepository {
    static func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            debugPrint("Error: \(error), \(error.userInfo)")
        }
    }

    static func rollback() {
        guard context.hasChanges else { return }
        context.rollback()
    }
}

// https://hajihaji-lemon.com/swift/coredata-nspredicate/ fetchのやり方
// https://www.fuwamaki.com/article/325 基本的に一番参考にした
// https://www.2nd-walker.com/2020/03/05/swift-basic-how-to-use-coredata/#tiao_jiande_jiaori_rumi 詳細な使用方法
