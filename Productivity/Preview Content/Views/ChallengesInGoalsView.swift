//
//  ChallengesInGoalsView.swift
//  Productivity
//
//  Created by Nick Werner on 08.10.25.
//

import SwiftUI


// Add this new component to your existing ChallengesView.swift file
// Add this new component to your existing ChallengesView.swift file
struct ChallengesInGoalsView: View {
    
    @ObservedObject var challengeManager: ChallengeManager
    let goal: GoalItem
    
    
    // Add the timer property here
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var newTodoText = ""
    @State private var showingAddAlert = false
    
    // New state variables for the timed challenge alert
    @State private var newChallengeDuration = ""
    @State private var showingAddTimerAlert = false
    @Binding var isEditing: Bool
    @State private var challengeToEdit: ChallengeItem?
    
    
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
                // --- ERSETZE DEN ALTEN VSTACK DURCH DIESE LIST ---
                List {
                    ForEach(challengeManager.challengeItems.filter { $0.associatedGoal == goal }) { challenge in
                        ChallengeRowInGoalView(
                            challengeManager: challengeManager,
                            challenge: challenge
                        ) {
                            challengeManager.toggleChallenge(challenge)
                        }
                        .contentShape(Rectangle()) // ganze Zeile tappable
                        .onTapGesture {
                            if isEditing { challengeToEdit = challenge }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 2, leading: 12, bottom: 5, trailing: 12))
                    }
                    .onDelete(perform: deleteChallenge)   // Swipe-to-Delete
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                .scrollDisabled(true)
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
                    challengeManager.addChallenge(newTodoText, associatedGoal: goal)
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
                    challengeManager.addChallengeWithTimer(newTodoText, durationInMinutes: duration, associatedGoal: goal)
                    newTodoText = ""
                    newChallengeDuration = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func deleteChallenge(at offsets: IndexSet) {
            // Finde zuerst heraus, welche Challenges in unserer gefilterten Liste angezeigt werden
            let challengesForGoal = challengeManager.challengeItems.filter { $0.associatedGoal == goal }
            
            // Finde anhand der Position (offsets) die spezifischen Challenges, die gelöscht werden sollen
            let challengesToDelete = offsets.map { challengesForGoal[$0] }
            
            // Gehe durch die zu löschenden Challenges und rufe die Löschfunktion im Manager auf
            for challenge in challengesToDelete {
                challengeManager.deleteChallenge(challenge)
            }
        }
        // --- ENDE DER NEUEN FUNKTION ---


    
}
    
struct ChallengeRowInGoalView: View {
    @ObservedObject var challengeManager: ChallengeManager
    let challenge: ChallengeItem
    let onToggle: () -> Void
    
    private var formattedTime: String {
        let minutes = challenge.timeRemaining / 60
        let seconds = challenge.timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        // This HStack contains your original row content
        HStack {
            if challenge.hasTimer {
                timerButton
            } else {
                toggleButton
            }
            
                Text(challenge.title)
                    .font(.headline)
                
               
            
            Spacer()
            
            Text("\(challenge.streak) days")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
       
    }
    
    private var toggleButton: some View {
        Button(action: onToggle) {
            Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(challenge.isCompleted ? .green : .gray)
                .font(.system(size: 30))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var timerButton: some View {
        VStack {
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
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 30))
            }
            
            Text(formattedTime)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
        }
    }
}
