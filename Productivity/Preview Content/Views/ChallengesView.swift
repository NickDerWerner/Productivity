//
//  ChallengesView.swift
//  Productivity
//
//  Created by Nick Werner on 10.09.25.
//

import SwiftUI

// STEP 1: Create the Todo Data Model
// This defines what a single todo item looks like
struct ChallengeItem: Identifiable, Codable {
    var id = UUID()        // Unique identifier for each todo
    var title: String      // The todo text
    var isCompleted: Bool = false  // Whether it's done or not
    var streak : Int = 0
    var streakGoal : Int = 100
    var isDailyChallenge: Bool = true //unused
    
    //for timer
    var hasTimer: Bool = false
       var timerDuration: Int = 0
       var isTimerRunning: Bool = false
       var timeRemaining: Int = 0
       var timerEndDate: Date?

}

// STEP 8: Create the main TodoListView
struct ChallengesView: View {
    // @StateObject creates and manages the TodoManager
    @StateObject private var challengeManager = ChallengeManager()
    
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
            if challengeManager.challengeItems.isEmpty {
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
                    ForEach(challengeManager.challengeItems) { challenge in
                        ChallengeRowView(challengeManager: challengeManager, challenge: challenge) { // Pass it here
                          challengeManager.toggleChallenge(challenge)
                        }
                    }
                    .onDelete(perform: challengeManager.deleteChallenge)
                }
                .listRowSpacing(20)
                
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
                    challengeManager.addChallenge(newTodoText)
                    newTodoText = ""  // Clear text field
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// STEP 14: Create individual todo row
// In the ChallengeRowView
struct ChallengeRowView: View {
    // You need to pass the manager in to call its functions
    @ObservedObject var challengeManager: ChallengeManager
    let challenge: ChallengeItem
    let onToggle: () -> Void
    
    // A helper to format time nicely (e.g., 90 seconds -> "01:30")
    private var formattedTime: String {
        let minutes = challenge.timeRemaining / 60
        let seconds = challenge.timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            Text(challenge.title)
                .font(.title2)
            
            
            if challenge.hasTimer {
                
                HStack{
                    VStack {
                        // Play/Pause Button
                        if !challenge.isCompleted {
                            Button(action: {
                                if challenge.isTimerRunning {
                                    challengeManager.pauseTimer(for: challenge)
                                } else {
                                    challengeManager.startTimer(for: challenge)
                                }
                            }) {
                                Image(systemName: challenge.isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                    .foregroundColor(challenge.isTimerRunning ? .orange : .blue)
                                    .font(.system(size: 30))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        else{
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 30))
                        }
                        // Timer display
                        Text(formattedTime)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    // Streak
                    Text("Streak: \(challenge.streak) \(challenge.streak == 1 ? "day" : "days")")
                    
                    
                    
                    
                }
                .offset(y: -10)
            } else{
                
                HStack {
                    
                    if !challenge.hasTimer {
                        Button(action: onToggle) {
                            Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(challenge.isCompleted ? .green : .gray)
                                .font(.system(size: 30))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                    Text("Streak: \(challenge.streak) \(challenge.streak == 1 ? "day" : "days")")
                } .offset(y: -13)
            }
        }
        .padding(.vertical, -5)
            
    }
}

// You'll need to update the ForEach loop in EmbeddedChallengesView to pass the manager
// ForEach(challengeManager.challengeItems) { challenge in
//     ChallengeRowView(challengeManager: challengeManager, challenge: challenge) { // Pass it here
//         challengeManager.toggleChallenge(challenge)
//     }
//     // ... rest of the code
// }


// Add this new component to your existing ChallengesView.swift file
// Add this new component to your existing ChallengesView.swift file
struct EmbeddedChallengesView: View {
    @StateObject private var challengeManager = ChallengeManager()
    
    // Add the timer property here
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var newTodoText = ""
    @State private var showingAddAlert = false
    
    // New state variables for the timed challenge alert
    @State private var newChallengeDuration = ""
    @State private var showingAddTimerAlert = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Title
            Text("My Challenges")
                .font(.title2)
                .fontWeight(.bold)
            
            // Check if we have challenges
            if challengeManager.challengeItems.isEmpty {
                // Show empty state
                VStack {
                    Image(systemName: "star.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No challenges yet!")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(minHeight: 100)
            } else {
                // Show challenges using VStack instead of List
                VStack(spacing: 15) {
                    ForEach(challengeManager.challengeItems) { challenge in
                        ChallengeRowView(challengeManager: challengeManager, challenge: challenge) { // Pass it here
                         challengeManager.toggleChallenge(challenge)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        
                    }
                }
                
            }
            
            // Add button for normal challenges
            Button("Add New Challenge") {
                showingAddAlert = true
            }
            .buttonStyle(.borderedProminent)
            
            // New button for timed challenges
            Button("Add Timed Challenge") {
                showingAddTimerAlert = true
            }
            .buttonStyle(.bordered)
            
        }
        // Add the .onReceive and .onAppear modifiers to the main VStack
        .onReceive(timer) { _ in
            challengeManager.updateAndCheckTimers() // For live updates
        }
        .onAppear {
            challengeManager.updateAndCheckTimers() // For syncing when the view loads ✅
        }
        .alert("Add New Challenge", isPresented: $showingAddAlert) {
            TextField("Enter challenge", text: $newTodoText)
            Button("Add") {
                if !newTodoText.isEmpty {
                    challengeManager.addChallenge(newTodoText)
                    newTodoText = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        // New alert for timed challenges
        .alert("Add Timed Challenge", isPresented: $showingAddTimerAlert) {
            TextField("Enter title", text: $newTodoText)
            TextField("Duration in minutes", text: $newChallengeDuration)
                .keyboardType(.numberPad) // Shows a numeric keyboard
            Button("Add") {
                if !newTodoText.isEmpty, let duration = Int(newChallengeDuration) {
                    challengeManager.addChallengeWithTimer(newTodoText, durationInMinutes: duration)
                    newTodoText = ""
                    newChallengeDuration = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }}
    




// STEP 15: Preview for testing
#Preview {
    EmbeddedChallengesView()
}
