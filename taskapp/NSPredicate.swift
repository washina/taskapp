//
//  NSPredicate.swift
//  taskapp
//
//  Created by YutaIwashina on 2017/04/10.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import Foundation

// 前後方一致検索
public extension NSPredicate {
    public convenience init(_ property: String, contains q: String) {
        self.init(format: "\(property) CONTAINS '\(q)'")
    }
}
