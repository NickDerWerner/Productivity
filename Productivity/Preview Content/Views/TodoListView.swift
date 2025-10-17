import SwiftUI

// Annahme: Du hast bereits ein TodoItem-Modell an anderer Stelle definiert.
// struct TodoItem: Identifiable, Codable { ... }
// struct TodoManager: ObservableObject { ... }

// MARK: - Main Todo List View
struct TodoListView: View {
    @ObservedObject var todoManager: TodoManager
    @State private var newTodoText = ""
    @State private var newDate: Date? = nil
    @State private var showingAddSheet = false
    
    private var sortedTodoList: [TodoItem]{
        todoManager.todoItems.sorted{$0.dueDate < $1.dueDate}
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("TODOs")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                
                Button() {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                }.padding()
                
              
            }
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
                
                
                // Liste mit Todos
                List {
                    ForEach(sortedTodoList) { todo in
                        VStack(alignment: .leading, spacing: 0) {
                            Divider().padding(.leading, 55)
                            
                            TodoRowView(todo: todo) {
                                todoManager.toggleTodo(todo)
                            }
                            
                            // Manuelle Trennlinie zwischen den Elementen
                            .frame(maxHeight: .infinity)
                            
                            
                               
                            
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
        }
        .sheet(isPresented: $showingAddSheet) {
                  // This is where you create and show your new sheet view
                  AddTodoSheetView(isPresented: $showingAddSheet, todoManager: todoManager)
              }
           }
}

// MARK: - Individual Todo Row View
struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    
    
    private var dueDateStatus: String{
        if todo.isCompleted{
            return ""
        }
        let calendar = Calendar.current
        let currentDay = calendar.startOfDay(for: Date())
        let todoDay = calendar.startOfDay(for: todo.dueDate)
        guard let daysUntilTodo = calendar.dateComponents([.day], from: currentDay, to: todoDay).day else{
            return ""
        }
        
        switch daysUntilTodo{
        case ..<0: // Any negative number (in the past)
            return "overdue by \(abs(daysUntilTodo)) day\(abs(daysUntilTodo) == 1 ? "" : "s")"
        case 0:
            return "due today"
        case 1:
            return "due tomorrow"
        default:
            return "due in \(daysUntilTodo) days"
       
        }
    }
    
    private var dueDateColor: Color{
        let calendar = Calendar.current
        let currentDay = calendar.startOfDay(for: Date())
        let todoDay = calendar.startOfDay(for: todo.dueDate)
        guard let daysUntilTodo = calendar.dateComponents([.day], from: currentDay, to: todoDay).day else{
            return .primary
        }
        switch daysUntilTodo{
        case ..<0:
            return .red
        case 0:
            return .orange
        default:
            return .secondary
        }
        
    }
    
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
            
            Text(dueDateStatus)
                .font(.caption) // Make it smaller than the title
                .foregroundColor(dueDateColor) // Use a lighter color
           
            
        }
       .padding(.vertical, 8)
        .padding(.horizontal) // Wichtig: Fügt seitlichen Abstand hinzu
    }
}


// Add this new view to your TodoListView.swift file





