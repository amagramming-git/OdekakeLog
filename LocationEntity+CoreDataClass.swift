//
//  LocationEntity+CoreDataClass.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/04.
//
//

import Foundation
import CoreData

@objc(LocationEntity)
public class LocationEntity: NSManagedObject {
    
    static func new(taskId: Int64,latitude: Double,longitude: Double,timestamp: Date) -> LocationEntity {
        let entity:LocationEntity = CoreDataRepository.entity()
        entity.taskId = taskId
        entity.latitude = latitude
        entity.longitude = longitude
        entity.timestamp = timestamp
        return entity
    }
    
}
