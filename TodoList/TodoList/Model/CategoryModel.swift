//
//  CategoryModel.swift
//  TodoList
//
//  Created by 김기현 on 2020/11/19.
//

import Foundation

struct CategoryModel {
    let categoryName: String?
    let createDate: Date?
    
    init(categoryName: String, createDate: Date) {
        self.categoryName = categoryName
        self.createDate = createDate
    }
}
