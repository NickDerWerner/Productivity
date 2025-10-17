import SwiftUI

// =============================================================================
// HOMEVIEW WITH EMBEDDED TODOLIST
// =============================================================================

struct HomeView: View {
    @ObservedObject var challengeManager: ChallengeManager
    @ObservedObject var todoManager: TodoManager
    var body: some View {
        NavigationView {
            ScrollView {  // ScrollView allows the whole home screen to scroll
                VStack(spacing: 20) {  // spacing: 20 adds consistent gaps between sections
                    let NrChallengeItems = challengeManager.challengeItems.count
                    let nrTodoItems = todoManager.todoItems.filter {
                    let due = $0.dueDate
                        return due < Date() || Calendar.current.isDateInToday(due)
                    }.count

                    let nrDoneChallenges = challengeManager.challengeItems.count(where: {$0.isCompleted == true})
                
                    let nrDoneTodos = todoManager.todoItems.filter {
                    let due = $0.dueDate
                        return (due < Date() || Calendar.current.isDateInToday(due)) && $0.isCompleted == true
                    }.count
                    
                    HomeProgressCard(done: nrDoneTodos + nrDoneChallenges, total: nrTodoItems + NrChallengeItems)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                        .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 15) {
                        // EMBEDDED TODO LIST
                        // This is the key part - we're using our TodoListView as a component
                        TodoListView(todoManager: todoManager)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                            
                            .padding(.horizontal)
                        
                           
                     
                    }
                    
                    // EMBEDDED CHALLENGES - FULL HEIGHT, NO BOX
                    EmbeddedChallengesView(challengeManager: challengeManager)  // Use the new component
                                          .padding(.horizontal)
                                      
                    
                    
                }
            }
        }
    }
}
