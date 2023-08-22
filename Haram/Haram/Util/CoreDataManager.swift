//
//  CoreDataManager.swift
//  Haram
//
//  Created by 이건준 on 2023/08/22.
//

import UIKit
import CoreData

final class CoreDataManager {
  static let shared = CoreDataManager()
  private init() {}
  
  let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
  lazy var context = appDelegate?.persistentContainer.viewContext
  
  let modelName: String = "RevisionOfTranslation"
  
  func getRevisionOfTranslation(ascending: Bool = false) -> [RevisionOfTranslation] {
    var models: [RevisionOfTranslation] = [RevisionOfTranslation]()
    
    if let context = context {
      let idSort: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: ascending)
      let fetchRequest: NSFetchRequest<NSManagedObject>
      = NSFetchRequest<NSManagedObject>(entityName: modelName)
      fetchRequest.sortDescriptors = [idSort]
      
      do {
        if let fetchResult: [RevisionOfTranslation] = try context.fetch(fetchRequest) as? [RevisionOfTranslation] {
          models = fetchResult
        }
      } catch let error as NSError {
        print("Could not fetch🥺: \(error), \(error.userInfo)")
      }
    }
    return models
  }
  
  func saveRevisionOfTranslations(
    models: [RevisionOfTranslationModel],
    onSuccess: @escaping ((Bool) -> Void)) {
      if let context = context,
         let entity: NSEntityDescription
          = NSEntityDescription.entity(forEntityName: modelName, in: context) {
        
        models.forEach { model in
          if let revisionOfTranslation: RevisionOfTranslation = NSManagedObject(entity: entity, insertInto: context) as? RevisionOfTranslation {
            revisionOfTranslation.id = model.id
            revisionOfTranslation.bibleName = model.bibleName
            revisionOfTranslation.chapter = model.chapter
            revisionOfTranslation.jeol = model.jeol
          }
        }
        
        contextSave { success in
          onSuccess(success)
        }
      }
    }
  
  func saveRevisionOfTranslation(
    model: RevisionOfTranslationModel,
    onSuccess: @escaping ((Bool) -> Void)) {
      if let context = context,
         let entity: NSEntityDescription
          = NSEntityDescription.entity(forEntityName: modelName, in: context) {
        
        if let revisionOfTranslation: RevisionOfTranslation = NSManagedObject(entity: entity, insertInto: context) as? RevisionOfTranslation {
          revisionOfTranslation.id = model.id
          revisionOfTranslation.bibleName = model.bibleName
          revisionOfTranslation.chapter = model.chapter
          revisionOfTranslation.jeol = model.jeol
          
          contextSave { success in
            onSuccess(success)
          }
        }
      }
    }
  
  func deleteRevisionOfTranslation(id: Int64, onSuccess: @escaping ((Bool) -> Void)) {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: id)
    
    do {
      if let results: [RevisionOfTranslation] = try context?.fetch(fetchRequest) as? [RevisionOfTranslation] {
        if results.count != 0 {
          context?.delete(results[0])
        }
      }
    } catch let error as NSError {
      print("Could not fatch🥺: \(error), \(error.userInfo)")
      onSuccess(false)
    }
    
    contextSave { success in
      onSuccess(success)
    }
  }
}

extension CoreDataManager {
  fileprivate func filteredRequest(id: Int64) -> NSFetchRequest<NSFetchRequestResult> {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult>
    = NSFetchRequest<NSFetchRequestResult>(entityName: modelName)
    fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
    return fetchRequest
  }
  
  fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
    do {
      try context?.save()
      onSuccess(true)
    } catch let error as NSError {
      print("Could not save🥶: \(error), \(error.userInfo)")
      onSuccess(false)
    }
  }
}
