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
        
        do {
            try context.save()
//            print("saved.\nname: \(name)\nduration: \(duration)\npath: \(path)")
        } catch {
            print(error)
        }
    }
    
    func getSound() -> [SoundModel]? {
        var soundModels = [SoundModel]()
        
        let fetchRequest: NSFetchRequest<Sound> = Sound.fetchRequest()
        do {
            
            let searchResults = try getContext().fetch(fetchRequest)
            for sound in searchResults as [NSManagedObject] {
                let soundName = sound.value(forKey: "name") as! String
                let soundPath = sound.value(forKey: "path") as! String
                let soundDuration = sound.value(forKey: "duration") as! Double
                
                let model = SoundModel(name: soundName, path: soundPath, duration: soundDuration)
                soundModels.append(model)
            }
        } catch let error as NSError {
            print(error)
        }
        
        return soundModels
    }
    
    func getContext() -> NSManagedObjectContext {
        let sharedDelegate = UIApplication.shared.delegate as! AppDelegate
        return sharedDelegate.persistentContainer.viewContext
    }
}
