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
                
                Text(challenge.associatedGoal.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("🔥: \(challenge.streak) day\(challenge.streak == 1 ? "" : "s")")

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
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var isEditing = false

    var body: some View {
        
            Group {
                if challengeManager.challengeItems.isEmpty {
                    VStack {
                        Image(systemName: "star.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No challenges yet!")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(challengeManager.challengeItems) { challenge in
                            ChallengeRowView(challengeManager: challengeManager, challenge: challenge) {
                                challengeManager.toggleChallenge(challenge)
                            }
                            // --- FIX 2: REMOVE .listRowInsets ---
                            // Spacing is now handled inside the ChallengeRowView.
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
                        }
                        .onMove(perform: challengeManager.moveChallenge)
                    }
                    .listStyle(.plain)
                    .scrollDisabled(true)
                    .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                    .frame(height: CGFloat(challengeManager.challengeItems.count) * 110)
                }
            }
            
//            .toolbar {
//                Button(isEditing ? "Done" : "Edit") {
//                    withAnimation {
//                        isEditing.toggle()
//                    }
//                }
//            }
        
        .onReceive(timer) { _ in
            challengeManager.updateAndCheckTimers()
        }
        .onAppear {
            challengeManager.updateAndCheckTimers()
        }
    }
}


