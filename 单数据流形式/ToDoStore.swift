//
//  ToDoStore.swift
//  单数据流形式
//
//  Created by 王宁 on 2017/7/16.
//  Copyright © 2017年 @David. All rights reserved.
//

import Foundation

let dummy = [
  "Buy the milk",
  "Take my dog",
  "Rent a car"
]

struct ToDoStore {
    
    static let shared = ToDoStore()
    func getTodoItems(completionHandler:(([String])->Void)?){
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
             completionHandler?(dummy)
        }
    }
    
}

