import SwiftUI

// STEP 8: Create the main TodoListView
struct TodoListView: View {
    // @StateObject creates and manages the TodoManager
    @StateObject private var todoManager = TodoManager()
    
    // @State variables for the UI
    @State private var newTodoText = ""
    @State private var showingAddAlert = false
    
    var body: some View {
        VStack {
            // STEP 9: Title
            Text("My Todo List")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // STEP 10: Check if we have todos
            if todoManager.todoItems.isEmpty {
                // Show empty state
                VStack {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No todos yet!")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // STEP 11: Show the todo list
                List {
                    ForEach(todoManager.todoItems) { todo in
                        TodoRowView(todo: todo) {
                            todoManager.toggleTodo(todo)
                        }
                    }
                    .onDelete(perform: todoManager.deleteTodos)
                }
            }
            
            // STEP 12: Add todo button
            Button("Add New Todo") {
                showingAddAlert = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        // STEP 13: Alert for adding new todos
        .alert("Add New Todo", isPresented: $showingAddAlert) {
            TextField("Enter todo", text: $newTodoText)
            Button("Add") {
                if !newTodoText.isEmpty {
                    todoManager.addTodo(newTodoText)
                    newTodoText = ""  // Clear text field
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// STEP 14: Create individual todo row
struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void  // Function to call when checkbox is tapped
    
    var body: some View {
        HStack {
            // Checkbox button
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())  // Removes button styling
            
            // Todo text
            Text(todo.title)
                .strikethrough(todo.isCompleted)  // Cross out when completed
                .foregroundColor(todo.isCompleted ? .secondary : .primary)
            
            Spacer()  // Pushes everything to the left
        }
        .padding(.vertical, 2)
    }
}

// STEP 15: Preview for testing
#Preview {
    TodoListView()
}
