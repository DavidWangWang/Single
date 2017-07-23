//
//  TableViewController.swift
//  单数据流形式
//
//  Created by 王宁 on 2017/7/16.
//  Copyright © 2017年 @David. All rights reserved.
//

import UIKit

let inputCellReuseId = "inputCell"
let todoCellResueId = "todoCell"

class TableViewController: UITableViewController {

    struct State:StateType {
        var dataSource = TableViewControllerDataSource(todos: [], owner: nil)
        var text:String = ""
    }
    enum Action:ActionType {
        case updateText(text:String)
        case addToDos(items:[String])
        case removeTodo(index:Int)
        case loadToDos
    }
    enum Command:CommandType {
        case loadToDos(complition:(([String])->Void))
        case someOtherCommand
    }
    
    var store:Store<Action,State,Command>!
    //通过外界传入的闭包，更新当前的状态。返回Command
    lazy var reduce:(State,Action)->(state:State,command:Command?) = {
        [weak self] (state:State,action:Action) in
        var state = state
        var command:Command? = nil
        switch action{
            case .updateText(let text):
              state.text = text
            case .addToDos(let items):
            state.dataSource = TableViewControllerDataSource(todos: state.dataSource.todos + items, owner: self)
        case .removeTodo(let index):
            let oldTodos = state.dataSource.todos
            state.dataSource = TableViewControllerDataSource.init(todos: Array(state.dataSource.todos[0..<index])+Array(state.dataSource.todos[index+1..<state.dataSource.todos.count]), owner: self)
        case .loadToDos:
            
            command = Command.loadToDos(complition: {  self?.store.dispatch(.addToDos(items: $0))
             })
        
        }
        
        return (state,command)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateSource = TableViewControllerDataSource(todos: [], owner: self)
        //初始化一个store
        store = Store<Action,State,Command>.init(reduce: reduce, initialState: State.init(dataSource: dateSource, text: ""))
        store.subscribe {[weak self] (state, previousState, command) in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)

        }
        
        stateDidChanged(state: store.state, previousState: nil, command: nil)
        
        store.dispatch(.loadToDos)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }

        
    }
    
    
    func stateDidChanged(state: State, previousState: State?, command: Command?) {
        if let command = command{
            switch command {
            case .loadToDos(let hander):
                ToDoStore.shared.getTodoItems(completionHandler: hander)
                
            case .someOtherCommand:
                break
            }
            //
            
        }
        if previousState == nil || previousState!.dataSource.todos != state.dataSource.todos {
            let dataSource = state.dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()
            title = "TODO - (\(dataSource.todos.count))"
        }
        if previousState == nil || previousState!.text != state.text{
            
            let isItemLengthEnough = state.text.characters.count >= 3
            navigationItem.rightBarButtonItem?.isEnabled = isItemLengthEnough
            let inputIndexPath = IndexPath(row: 0, section: TableViewControllerDataSource.Section.input.rawValue)
            let inputCell = tableView.cellForRow(at: inputIndexPath) as? TableViewInputCell
            inputCell?.textField.text = state.text
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == TableViewControllerDataSource.Section.todos.rawValue else{return}
        store.dispatch(.removeTodo(index: indexPath.row))
    }
    @IBAction func addButtonPressed(_ sender: Any) {
        store.dispatch(.addToDos(items: [store.state.text]))
        store.dispatch(.updateText(text: ""))
    }
}

extension TableViewController: TableViewInputCellDelegate {
    func inputChanged(cell: TableViewInputCell, text: String) {
        store.dispatch(.updateText(text: text))
    }
}




