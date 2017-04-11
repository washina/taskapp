//
//  Task.swift
//  taskapp
//
//  Created by YutaIwashina on 2017/04/10.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // カテゴリ
    dynamic var category = ""
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
