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
            
            VStack(alignment: .leading) {
                Text(challenge.title)
                    .font(.headline)
                
                Text(challenge.associatedGoal?.title ?? "Routine")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        .padding(.vertical, -6)
    }
}


// MARK: - Main Embedded Challenges View (SIMPLIFIED)
struct EmbeddedChallengesView: View {
    @ObservedObject var challengeManager: ChallengeManager
    @State private var showAddToRoutineView: Bool = false
    @State private var challengeToAdd: ChallengeItem?
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        
        // REMOVE THE Group AND THE if/else WRAPPER
        
        List {
            // This ForEach is now the List's main content.
            // If challengeItems is empty, the ForEach simply does nothing.
            ForEach(challengeManager.challengeItems.filter { $0.isSubChallange == false})
            { challenge in
                if challenge.isAggregator {
                    
                    // This is the correct structure
                    DisclosureGroup {
                      
                        
                        ForEach(challengeManager.challengeItems.filter { $0.associatedAggregatorID == challenge.id }) { subChallenge in
                            
                            // This displays one row for each sub-challenge
                            ChallengeRowView(challengeManager: challengeManager, challenge: subChallenge) {
                                challengeManager.toggleChallenge(subChallenge)
                            }//listmodifiers after this
                            .listRowSeparator(.hidden)
                            
                            // You might want to add some indentation
                            .padding(.leading, 20)
                            .padding(.top, -20)
                        }
                        
                    } label: {
                        
                        ChallengeRowView(challengeManager: challengeManager, challenge: challenge) {
                            challengeManager.toggleChallenge(challenge)
                        }
                        .contextMenu {
                            Button(action: {
                                           //hier noch gleiches menu adden
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
                    .sheet(isPresented: $showAddToRoutineView){
                        // --- (FIXED THIS LINE TOO, see below) ---
                        AddToRoutineView(
                            challengeManager: challengeManager,
                            isPresented: $showAddToRoutineView, // Pass as a Bindingf
                            challengeToAdd: $challengeToAdd // Pass as a Binding
                        )
                        .presentationDetents([.medium, .large])
                    }
                }}
            .onMove(perform: challengeManager.moveChallenge)
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
