//
//  Category.swift
//  RoutiNier
//
//  Created by Nazar Petruk on 10/06/2019.
//  Copyright © 2019 Nazar Petruk. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let item = List<Item>()
}

