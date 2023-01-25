//
//  Address.swift
//  favoritePlaces_simran_C0870768
//
//  Created by simran mehra on 2023-01-24.
//

import CoreData

class Address: NSManagedObject {
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var name: String?
    @NSManaged var longitude: NSDecimalNumber?
    @NSManaged var latitude: NSDecimalNumber?
}
