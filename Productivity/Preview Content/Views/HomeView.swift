import SwiftUI

// =============================================================================
// HOMEVIEW WITH EMBEDDED TODOLIST
// =============================================================================

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {  // ScrollView allows the whole home screen to scroll
                VStack(spacing: 20) {  // spacing: 20 adds consistent gaps between sections
                    
                    VStack(alignment: .leading, spacing: 15) {
                        // EMBEDDED TODO LIST
                        // This is the key part - we're using our TodoListView as a component
                        TodoListView()
                            .frame(minHeight: 300)  // Give it minimum space
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal)
                    }
                    
                    // EMBEDDED CHALLENGES - FULL HEIGHT, NO BOX
                                      EmbeddedChallengesView()  // Use the new component
                                          .padding(.horizontal)
                                      
                                      Spacer(minLength: 50)  // Bottom spacing
                }
            }
        }
    }
}
// =============================================================================
// SUPPORTING COMPONENTS
// =============================================================================

/*
 QUICK STAT CARD COMPONENT:
 - Reusable card that shows a stat with icon
 - Takes parameters to customize appearance
 - Good example of component design
*/
struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

/*
 ACTIVITY ROW COMPONENT:
 - Shows recent activity items
 - Demonstrates how to create list-like items without using List
*/
struct ActivityRow: View {
    let icon: String
    let text: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.body)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// =============================================================================
// PREVIEW
// =============================================================================

#Preview {
    HomeView()
}

/*
 KEY CONCEPTS DEMONSTRATED:

 1. COMPOSITION:
    - HomeView uses TodoListView as a building block
    - Each section is a separate component
    - Easy to rearrange, modify, or reuse

 2. LAYOUT TECHNIQUES:
    - ScrollView for scrollable content
    - VStack/HStack for arrangement
    - Spacing and padding for visual breathing room

 3. COMPONENT REUSABILITY:
    - QuickStatCard can be used anywhere with different data
    - ActivityRow creates consistent activity displays
    - TodoListView works as both standalone and embedded

 4. VISUAL HIERARCHY:
    - Different font sizes create information hierarchy
    - Colors guide attention to important elements
    - Spacing creates logical groupings

 5. RESPONSIVE DESIGN:
    - Horizontal scroll for cards on smaller screens
    - Flexible layouts that work on different device sizes
    - Proper use of Spacer() for dynamic layouts

 INTEGRATION EXPLANATION:
 - We import TodoListView just like any other component
 - It brings its own data management (TodoManager)
 - HomeView doesn't need to know how todos work internally
 - This is called "encapsulation" - hiding complexity behind simple interfaces
*/
