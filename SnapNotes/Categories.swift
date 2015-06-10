//
//  Categories.swift
//  SnapNotes
//
//  Created by Abdullah on 10/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import Foundation

class Categories {
    let id: String
    let name: String
    let order: Int
    
    init(id: String, name:String, order: Int) {
        self.id = id
        self.name = name
        self.order = order
    }
}