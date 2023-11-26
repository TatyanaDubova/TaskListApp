//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Татьяна Дубова on 25.11.2023.
//

import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    private let context: NSManagedObjectContext
    
    // MARK: - CoreDataStack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    private func fetchTask(id: UUID) -> Task? {
        let fetchRequest = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        var result: Task?
        do {
            result = try context.fetch(fetchRequest).first
        } catch {
            print(error)
        }
        return result
    }
    
    func fetchData() -> [TaskStruct] {
        let fetchRequest = Task.fetchRequest()
        var result: [TaskStruct] = []
        do {
            result = try context.fetch(fetchRequest).compactMap {
                var task: TaskStruct?
                if let title = $0.title, let id = $0.id {
                    task = TaskStruct(title: title, id: id)
                }
                return task
            }
        } catch {
            print(error)
        }
        return result
    }
    
    func addTask(_ task: TaskStruct) {
        let taskObject = Task(context: context)
        taskObject.id = task.id
        taskObject.title = task.title
        saveContext()
    }
    
    func deleteTask(_ id: UUID) {
        guard let taskObject = fetchTask(id: id) else { return }
        context.delete(taskObject)
        saveContext()
    }
    
    func updateTask(_ task: TaskStruct) {
        guard let taskObject = fetchTask(id: task.id) else { return }
        taskObject.title = task.title
        saveContext()
    }
    
    // MARK: - CoreDataSavingSupport
    func saveContext () {
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
