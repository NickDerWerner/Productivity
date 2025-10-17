//
//  AddTodoSheetView.swift
//  Productivity
//
//  Created by Nick Werner on 16.10.25.
//
import SwiftUI

struct AddTodoSheetView: View {
    // This allows the sheet to dismiss itself
    @Binding var isPresented: Bool
    
    // A reference to your data manager
    @ObservedObject var todoManager: TodoManager
    
    // Local state for the new todo's data
    @State private var newTodoText = ""
    @State private var newDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter todo", text: $newTodoText)
                
                // The DatePicker works perfectly inside a Form
                DatePicker("Due Date", selection: $newDate, displayedComponents: .date)
            }
            .navigationTitle("New Todo")
            .navigationBarItems(
                leading: Button("Cancel") {
                    
                    isPresented = false // Dismiss the sheet
                },
                trailing: Button("Add") {
                    if !newTodoText.isEmpty {
                        // Call the manager with both text and date
                        todoManager.addTodo(newTodoText, dueDate: newDate)
                        isPresented = false // Dismiss the sheet
                    }
                }
            )
        }
    }
}
