//
//  TodoListManager.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//
import SwiftUI

class TodoManager: ObservableObject {
    // @Published means SwiftUI will update the view when this changes
    @Published var todoItems: [TodoItem] = []
    
    // UserDefaults is like a simple database on the device
    private let userDefaults = UserDefaults.standard
    private let todosKey = "SavedTodos"  // Key name for storing todos
    
    // This runs when TodoManager is created
    init() {
        loadTodos()  // Load existing todos when app starts
    }
    
    // STEP 3: Load todos from storage
    func loadTodos() {
        // Try to get saved data from UserDefaults
        if let data = userDefaults.data(forKey: todosKey),
           let decodedTodos = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todoItems = decodedTodos  // Use saved todos
        }
        // If no saved todos exist, todoItems stays empty (which is fine)
    }
    
    // STEP 4: Save todos to storage
    func saveTodos() {
        // Convert todos to JSON data and save
        if let encodedData = try? JSONEncoder().encode(todoItems) {
            userDefaults.set(encodedData, forKey: todosKey)
        }
    }
    
    // STEP 5: Add a new todo
    func addTodo(_ title: String) {
        let newTodo = TodoItem(title: title)
        todoItems.append(newTodo)  // Add to list
        saveTodos()  // Save immediately
    }
    
    // STEP 6: Toggle todo completion
    func toggleTodo(_ todo: TodoItem) {
        // Find the todo in the list and flip its completed status
        if let index = todoItems.firstIndex(where: { $0.id == todo.id }) {
            todoItems[index].isCompleted.toggle()
            saveTodos()  // Save immediately
        }
    }
    
    // STEP 7: Delete todos
    func deleteTodos(at offsets: IndexSet) {
        todoItems.remove(atOffsets: offsets)
        saveTodos()  // Save immediately
    }
}
