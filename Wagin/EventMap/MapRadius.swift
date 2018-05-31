//
//  MapRadius.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/31/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class MapRadius: MKCircle {
    var name: String?
    var color: UIColor?

    convenience init(origin: CLLocationCoordinate2D, radius: Int, color: UIColor) {
        self.init(center: origin, radius: Double(radius))
        self.color = color
    }
}
