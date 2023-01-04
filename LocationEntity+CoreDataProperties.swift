//
//  LocationEntity+CoreDataProperties.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/04.
//
//

import Foundation
import CoreData


extension LocationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        return NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var taskId: Int64
    @NSManaged public var timestamp: Date?

}

extension LocationEntity : Identifiable {

}
