//
//  ActivityEntity+CoreDataClass.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/07.
//
//

import Foundation
import CoreData

@objc(ActivityEntity)
public class ActivityEntity: NSManagedObject {
    static func new(taskId: Int64) -> ActivityEntity {
        let entity:ActivityEntity = CoreDataRepository.entity()
        entity.taskId = taskId
        return entity
    }
    func setStartDate(startDate: Date) {
        self.startDate = startDate
    }
    func setEndDate(endDate: Date) {
        self.endDate = endDate
    }
}
