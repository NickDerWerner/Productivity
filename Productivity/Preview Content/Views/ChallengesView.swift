//
//  ChallengesView.swift
//  Productivity
//
//  Created by Nick Werner on 10.09.25.
//

import SwiftUI

// STEP 1: Create the Todo Data Model
// This defines what a single todo item looks like




// MARK: - Challenge Row View (WITH STYLING)
struct ChallengeRowView: View {
    @ObservedObject var challengeManager: ChallengeManager
   
    
    let challenge: ChallengeItem
    let onToggle: () -> Void
    var isExpanded: Bool? = nil
    
    private var formattedTime: String {
        let minutes = challenge.timeRemaining / 60
        let seconds = challenge.timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        // This HStack contains your original row content
       
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
        HStack {//hier ist alles drinnen
            
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
            
            VStack(alignment: .leading) { //hier kommt Titel untertitel und flammen rein dabei sind titel und flammen in einem HStack
                HStack{//titel und flamme
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(isActiveToday ? .black : .gray)
                    
                    Spacer()
                    
                    Text("🔥\(challenge.streak)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.trailing, (isExpanded == nil) ? 20 : 0)
                    
                }
               
                    
                HStack{//untertitel
                    Text(challenge.associatedGoal?.title ?? "Routine")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                 
                    
                    Text("🗓️: \(challenge.activeDaysSummary)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
        
           
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
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
        .padding(.vertical, -6)
    }
}


// MARK: - Main Embedded Challenges View (SIMPLIFIED)
struct EmbeddedChallengesView: View {
    @ObservedObject var challengeManager: ChallengeManager
    @State private var showAddToRoutineView: Bool = false
    @State private var challengeToAdd: ChallengeItem?
    @State private var expandedRoutines: Set<UUID> = []
    @State private var showingAddChallengeView: Bool = false
    @State private var routineToAddChallengeTo: UUID?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        
        // REMOVE THE Group AND THE if/else WRAPPER
        
        List {
            // This ForEach is now the List's main content.
            // If challengeItems is empty, the ForEach simply does nothing.
            ForEach(challengeManager.challengeItems.filter { $0.isSubChallange == false})
            { challenge in
                if challenge.isAggregator {
                   
              DisclosureGroup() {
                        
                        
                        ForEach(challengeManager.challengeItems.filter { $0.associatedAggregatorID == challenge.id }) { subChallenge in
                            
                            // This displays one row for each sub-challenge
                            ChallengeRowView(challengeManager: challengeManager, challenge: subChallenge) {
                                challengeManager.toggleChallenge(subChallenge)
                            }//listmodifiers after this
                            .contextMenu{
                                Button(action: {
                                    challengeManager.removeChallengeFromAggregator(challengeItem: subChallenge)
                                }) {
                                    Text("Remove from Routine")
                                    
                                }
                                Button(role: .destructive) {
                                    challengeManager.deleteChallenge(subChallenge)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                            }
                            // stiling for subChallenges
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    // Use insets for spacing and indentation
                                    // (2 base + 20 indent = 22 leading)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 5, trailing: 20)) // <-- This is the line                                    // end of stiling
                        }
                        
                    } label: {
                        
                        ChallengeRowView(
                                    challengeManager: challengeManager,
                                    challenge: challenge,
                                    onToggle: { challengeManager.toggleChallenge(challenge) },
                                    isExpanded: expandedRoutines.contains(challenge.id) // Pass it here
                                        )
                        .contextMenu {
                            Button(action: {
                                routineToAddChallengeTo = challenge.id
                                showingAddChallengeView = true
                                //hier noch gleiches menu adden
                            }) {
                                // This is the button's label in the menu
                                Text("Add Routine Habit")
                                Image(systemName: "plus.circle")
                            }
                            Button(role: .destructive) {
                                challengeManager.deleteChallenge(challenge)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                      
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
                                        // --- END OF ADDITIONS ---
                    
                    
                }else{
                    
                    
                    
                    ChallengeRowView(challengeManager: challengeManager, challenge: challenge) {
                        challengeManager.toggleChallenge(challenge)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
                    .contextMenu {
                        Button {
                            self.challengeToAdd = challenge
                            self.showAddToRoutineView = true
                        } label: {
                            Label("Add to Routine", systemImage: "plus")
                        }
                        Button(role: .destructive) {
                            challengeManager.deleteChallenge(challenge)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                   
                }
            }//end of ForEach
            .onMove(perform: challengeManager.moveChallenge)
        }
        .sheet(isPresented: $showAddToRoutineView){
            // --- (FIXED THIS LINE TOO, see below) ---
            AddToRoutineView(
                challengeManager: challengeManager,
                isPresented: $showAddToRoutineView, // Pass as a Binding
                challengeToAdd: $challengeToAdd // Pass as a Binding
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingAddChallengeView){
            AddRoutineChallengeView(showingAddChallengeView: $showingAddChallengeView, challengeManager: challengeManager, parentIDForAdding: $routineToAddChallengeTo)
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .frame(height: CGFloat(challengeManager.challengeItems.count) * 110)
        
        .overlay {
            // This view is shown *on top* of the List if it's empty
            if challengeManager.challengeItems.isEmpty {
                VStack {
                    Image(systemName: "star.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .padding(.top, 130)
                    Text("No challenges yet! Add in Goals")
                        .foregroundColor(.secondary)
                        .padding()
                }
               
                .frame(height: 400)
            }
        }
        .onReceive(timer) { _ in
            challengeManager.updateAndCheckTimers()
        }
        .onAppear {
            challengeManager.updateAndCheckTimers()
        }
    }
}
