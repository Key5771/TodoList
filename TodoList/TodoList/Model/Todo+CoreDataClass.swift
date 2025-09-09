//
//  Todo+CoreDataClass.swift
//  TodoList
//
//  Created by AI Assistant on 2025/09/09.
//

import Foundation
import CoreData

@objc(Todo)
public class Todo: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // 새 Todo 생성 시 기본값 설정
        if isCompleted == false && createDate == nil {
            createDate = Date()
            isCompleted = false
        }
    }
}
