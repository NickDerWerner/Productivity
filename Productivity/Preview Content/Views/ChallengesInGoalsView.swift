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

                    ForEach(challengeManager.challengeItems.filter {$0.associatedGoal == goal}) { challenge in
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
    }}
    
