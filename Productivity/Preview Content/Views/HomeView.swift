import SwiftUI

// =============================================================================
// HOMEVIEW WITH EMBEDDED TODOLIST
// =============================================================================

struct HomeView: View {
    @ObservedObject var challengeManager: ChallengeManager
    var body: some View {
        NavigationView {
            ScrollView {  // ScrollView allows the whole home screen to scroll
                VStack(spacing: 20) {  // spacing: 20 adds consistent gaps between sections
                    
                    VStack(alignment: .leading, spacing: 15) {
                        // EMBEDDED TODO LIST
                        // This is the key part - we're using our TodoListView as a component
                        TodoListView()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal)
                    }
                    
                    // EMBEDDED CHALLENGES - FULL HEIGHT, NO BOX
                    EmbeddedChallengesView(challengeManager: challengeManager)  // Use the new component
                                          .padding(.horizontal)
                                      
                                      Spacer(minLength: 50)  // Bottom spacing
                    
                    
                }
            }
        }
    }
}
