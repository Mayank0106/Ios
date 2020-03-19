//
//  Person+CoreDataProperties.swift
//  HitList
//
//  Created by Mayank Sharma on 19/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?

}
