//
//  Location.swift
//  favoritePlaces_rishivarma_c0880853
//
//  Created by RISHI VARMA on 2023-01-24.
//

import Foundation
import MapKit

class Location : NSObject, MKAnnotation {
    
    var title: String?
    
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        
    }

}

