//
//  ContentView.swift
//  TodoList
//
//  Created by Dmitrii Nikulin on 8/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View { AppAssembler.shared.makeTodoListModule() }
}

#Preview { ContentView() }
