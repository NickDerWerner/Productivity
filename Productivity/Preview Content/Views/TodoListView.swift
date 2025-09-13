import SwiftUI

// STEP 1: Create the Todo Data Model
// This defines what a single todo item looks like
struct TodoItem: Identifiable, Codable {
    let id = UUID()        // Unique identifier for each todo
    var title: String      // The todo text
    var isCompleted: Bool = false  // Whether it's done or not
}

// STEP 2: Create the Todo Manager
// This handles all the data operations (save, load, add, delete)
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
