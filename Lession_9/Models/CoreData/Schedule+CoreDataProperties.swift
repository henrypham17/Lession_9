//
//  Schedule+CoreDataProperties.swift
//  Lession_9
//
//  Created by Quang Phạm on 27/6/24.
//
//

import Foundation
import CoreData


extension Schedule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule> {
        return NSFetchRequest<Schedule>(entityName: "Schedule")
    }

    @NSManaged public var action: String?
    @NSManaged public var body: String?
    @NSManaged public var dateSchedule: Date?

}

extension Schedule : Identifiable {

}
