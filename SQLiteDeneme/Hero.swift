//
//  Hero.swift
//  SQLiteDeneme
//
//  Created by Enes Özkırdeniz on 21.10.2022.
//

import Foundation
import UIKit

class Hero {
    
    var id : Int
    var name : String?
    var power : Int
    
    init(id: Int, name: String? = nil, power: Int) {
        self.id = id
        self.name = name
        self.power = power
    }
}
