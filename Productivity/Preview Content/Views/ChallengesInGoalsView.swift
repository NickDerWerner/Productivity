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
    @Binding var showingAddSheet: Bool
    @Binding var parentIDForAdding: UUID?
    
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
                    ForEach(challengeManager.challengeItems.filter { $0.associatedGoal == goal}) { challenge in
                        
                        if challenge.isAggregator {
                            
                            // This is the correct structure
                            DisclosureGroup {
                              
                                
                                ForEach(challengeManager.challengeItems.filter { $0.associatedAggregatorID == challenge.id }) { subChallenge in
                                    
                                    // This displays one row for each sub-challenge
                                    ChallengeRowInGoalView(challengeManager: challengeManager, challenge: subChallenge) {
                                        challengeManager.toggleChallenge(subChallenge)
                                    }//listmodifiers after this
                                    .listRowSeparator(.hidden)
                                    
                                    // You might want to add some indentation
                                    .padding(.leading, 20)
                                    .padding(.top, -20)
                                }
                                
                            } label: {
                                
                                ChallengeRowInGoalView(challengeManager: challengeManager, challenge: challenge) {
                                    challengeManager.toggleChallenge(challenge)
                                }
                                .contextMenu {
                                    Button(action: {
                                                    // The action is the *same logic* as before
                                                    self.parentIDForAdding = challenge.id // Set the parent ID
                                                    self.showingAddSheet = true          // Show the sheet
                                                }) {
                                                    // This is the button's label in the menu
                                                    Text("Add Sub-Challenge")
                                                    Image(systemName: "plus.circle")
                                                }
                                }
                                .listRowSeparator(.hidden)
                                // Add your list modifiers for the main aggregator row here
                                // (e.g., .listRowSeparator(.hidden), .listRowInsets(...))
                            }
                        }else{
                            
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
                    }
                    .onDelete(perform: deleteChallenge)   // Swipe-to-Delete
                    .deleteDisabled(!isEditing)
                    
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                .scrollDisabled(true)
                .listRowSeparator(.hidden)
            }
            
           
            
        }
        
        // Add the .onReceive and .onAppear modifiers to the main VStack
        .onReceive(timer) { _ in
            challengeManager.updateAndCheckTimers() // For live updates
        }
        .onAppear {
            challengeManager.updateAndCheckTimers() // For syncing when the view loads ✅
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
            //check if challegne is active today
            //check if challegne is active today
                        let isActiveToday: Bool = {
                            // If the activeDays set is empty, we'll assume it's active every day.
                            if challenge.activeDays.isEmpty {
                                return true
                            }
                            
                            // Get the current weekday Int (Sunday=1, Monday=2...)
                            // This matches your DayOfWeek enum's raw values.
                            let currentWeekdayInt = Calendar.current.component(.weekday, from: Date())
                            
                            // Try to convert that Int into our DayOfWeek enum
                            guard let currentDay = DayOfWeek(rawValue: currentWeekdayInt) else {
                                return false // Should never happen, but good to be safe
                            }
                            
                            // Check if the challenge's set contains the current day
                            return challenge.activeDays.contains(currentDay)
                        }() // The () at the end immediately runs this closure
            
            if isActiveToday{
                if challenge.hasTimer {
                    timerButton
                } else {
                    toggleButton
                }}
            else{
                Image(systemName: "x.circle")
                    .foregroundColor(.gray)
                    .font(.system(size: 30))
            }
            
            VStack(alignment: .leading) {
                Text(challenge.title)
                    .font(.headline)
                    .foregroundColor(isActiveToday ? .black : .gray)
                    
                HStack{
                    Text(challenge.associatedGoal?.title ?? "Routine")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                   
                    
                    Text("  🗓️: \(challenge.activeDaysSummary)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("🔥\(challenge.streak)")
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
