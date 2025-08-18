//
//  TodoListApp.swift
//  TodoList
//
//  Created by Dmitrii Nikulin on 8/17/25.
//

import SwiftUI

@main
struct TodoListApp: App {
    var body: some Scene {
        WindowGroup {
            AppAssembler.shared.makeTodoListModule()
        }
    }
}
