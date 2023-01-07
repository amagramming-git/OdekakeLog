//
//  ActivityEntity+CoreDataProperties.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/07.
//
//

import Foundation
import CoreData


extension ActivityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityEntity> {
        return NSFetchRequest<ActivityEntity>(entityName: "ActivityEntity")
    }

    @NSManaged public var taskId: Int64
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?

}

extension ActivityEntity : Identifiable {

}
