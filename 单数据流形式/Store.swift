//
//  Store.swift
//  单数据流形式
//
//  Created by 王宁 on 2017/7/16.
//  Copyright © 2017年 @David. All rights reserved.
//

import Foundation

//动作的类型
protocol ActionType{}
//状态的类型
protocol StateType{}
//命令的类型
protocol CommandType{}



class Store<A:ActionType,S:StateType,C:CommandType> {
    
    let reduce:(_ state:S,_ action:A)->(S,C?)
//    var subscriber: ((_ state: S, _ previousState: S, _ command: C?) -> Void)?
    var subscriber: ((_ state: S, _ previousState: S, _ command: C?) -> Void)?

    var state: S
    init(reduce: @escaping (S, A) -> (S, C?),initialState:S) {
        self.reduce = reduce
        self.state = initialState
    }
    func subscribe(_ hander:@escaping ((S,S,C?)->Void)){
        
        self.subscriber = hander
    }
    
    func unsubscribe() {
        self.subscriber = nil
    }
    //
    func dispatch(_ action:A){
        let previousState = state
        let (nextState,command ) = reduce(state,action)
        state = nextState
        subscriber?(state, previousState, command)
    }
}







