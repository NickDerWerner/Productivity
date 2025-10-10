import SwiftUI

// Annahme: Du hast bereits ein TodoItem-Modell an anderer Stelle definiert.
// struct TodoItem: Identifiable, Codable { ... }
// struct TodoManager: ObservableObject { ... }

// MARK: - Main Todo List View
struct TodoListView: View {
    @StateObject private var todoManager = TodoManager()
    @State private var newTodoText = ""
    @State private var showingAddAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("My Todo List")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            if todoManager.todoItems.isEmpty {
                // Leerer Zustand
                VStack {
                    Text("No todos yet!")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                
            } else {
                // OBERE TRENNLINIE
                Divider().padding(.leading, 55)
                
                // Liste mit Todos
                List {
                    ForEach(todoManager.todoItems) { todo in
                        VStack(alignment: .leading, spacing: 0) {
                            TodoRowView(todo: todo) {
                                todoManager.toggleTodo(todo)
                            }
                            
                            // Manuelle Trennlinie zwischen den Elementen
                            .frame(maxHeight: .infinity)
                                Divider().padding(.leading, 55)
                            
                        }
                        // DIESE ZEILE IST DIE KORREKTUR
                        .listRowBackground(Color.clear) // Macht den Zeilenhintergrund transparent
                    }
                    .onDelete(perform: todoManager.deleteTodos)
                    .listRowSeparator(.hidden) // Versteckt die automatischen Linien
                    .listRowInsets(EdgeInsets())    // Entfernt Standard-Einrückung für volle Kontrolle
                }
                .listStyle(.plain)
                .frame(height: CGFloat(todoManager.todoItems.count) * 44) // Höhe pro Zeile angepasst
                .scrollDisabled(true)
            }
            
            Button("Add New Todo") {
                showingAddAlert = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 15)
            
            Spacer(minLength: 15)
        }
        .alert("Add New Todo", isPresented: $showingAddAlert) {
            TextField("Enter todo", text: $newTodoText)
            Button("Add") {
                if !newTodoText.isEmpty {
                    todoManager.addTodo(newTodoText)
                    newTodoText = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// MARK: - Individual Todo Row View
struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(todo.title)
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal) // Wichtig: Fügt seitlichen Abstand hinzu
    }
}

// MARK: - Preview
#Preview {
    struct PreviewContainer: View {
        var body: some View {
            ScrollView {
                VStack {
                    TodoListView()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .padding()
                    Spacer()
                }
            }
        }
    }
    return PreviewContainer()
}

