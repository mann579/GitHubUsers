//
//  UserCD+CoreDataProperties.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//
//

import Foundation
import CoreData


extension UserCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCD> {
        return NSFetchRequest<UserCD>(entityName: "UserCD")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var id: Int32
    @NSManaged public var login: String?
    @NSManaged public var reposUrl: String?

}

extension UserCD : Identifiable {

}
