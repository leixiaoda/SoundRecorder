//
//  DataMgr.swift
//  SoundRecorder
//
//  Created by 雷达 on 2017/2/25.
//  Copyright © 2017年 雷达. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class DataMgr: NSObject {
    
    func storeSound(model: SoundModel) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: SOUND_ENTITY_NAME, in: context)
        
        if (entity == nil) {
            print("entity is empty.")
            return
        }
        
        let sound = NSManagedObject(entity: entity!, insertInto: context)
        sound.setValue(model.name, forKey: "name")
        sound.setValue(model.path, forKey: "path")
        sound.setValue(model.duration, forKey: "duration")
        sound.setValue(model.createTime, forKey: "createTime")
        
        do {
            try context.save()
//            print("saved.\nname: \(name)\nduration: \(duration)\npath: \(path)")
        } catch {
            print(error)
        }
    }
    
    func getSound() -> [SoundModel]? {
        var soundModels = [SoundModel]()
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Sound> = Sound.fetchRequest()
        do {
            let searchResults = try context.fetch(fetchRequest)
            for sound in searchResults as [NSManagedObject] {
                let name = sound.value(forKey: "name") as! String
                let path = sound.value(forKey: "path") as! String
                let duration = sound.value(forKey: "duration") as! Double
                let createTime = sound.value(forKey: "createTime") as! Date
                let model = SoundModel(name: name, path: path, duration: duration, createTime: createTime)
                soundModels.append(model)
            }
        } catch let error as NSError {
            print(error)
        }
        
        return soundModels
    }
    
    func deleteSound(createTimeDemand: Date) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Sound> = Sound.fetchRequest()
        do {
            let searchResults = try context.fetch(fetchRequest)
            for sound in searchResults as [NSManagedObject] {
                let createTime = sound.value(forKey: "createTime") as! Date
                if createTime == createTimeDemand {
                    context.delete(sound)
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }

    
    func deleteAllSound() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Sound> = Sound.fetchRequest()
        do {
            let searchResults = try context.fetch(fetchRequest)
            for sound in searchResults as [NSManagedObject] {
                context.delete(sound)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        let sharedDelegate = UIApplication.shared.delegate as! AppDelegate
        return sharedDelegate.persistentContainer.viewContext
    }
}
