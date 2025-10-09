//
//  ChallengesView.swift
//  Productivity
//
//  Created by Nick Werner on 10.09.25.
//

import SwiftUI

// STEP 1: Create the Todo Data Model
// This defines what a single todo item looks like




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
                    VStack { //button links mit Zeit drunter
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
                    Text(" \(challenge.streak) \(challenge.streak == 1 ? "day" : "days")")
                    
                    
                    
                    
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
                    Text(" \(challenge.streak) \(challenge.streak == 1 ? "day" : "days")")
                } .offset(y: -13)
            }
            Text(" \(challenge.associatedGoal.title) ")
                .padding(.vertical, -30)
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
    @ObservedObject var challengeManager: ChallengeManager
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
            
        
            
        }
        // Add the .onReceive and .onAppear modifiers to the main VStack
        .onReceive(timer) { _ in
            challengeManager.updateAndCheckTimers() // For live updates
        }
        .onAppear {
            challengeManager.updateAndCheckTimers() // For syncing when the view loads ✅
        }
       
    }}
    










