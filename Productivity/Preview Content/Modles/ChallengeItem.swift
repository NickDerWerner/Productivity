//
//  ChallengeItem.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//
import SwiftUI

struct ChallengeItem: Identifiable, Codable {
    var id = UUID()        // Unique identifier for each todo
    var title: String      // The todo text
    var isCompleted: Bool = false  // Whether it's done or not
    var streak : Int = 0
    var streakGoal : Int = 100
    var isDailyChallenge: Bool = true //unused
    var associatedGoal: GoalItem
    var associatedSubGoal: SubgoalItem?
    //for timer
    var hasTimer: Bool = false
       var timerDuration: Int = 0
       var isTimerRunning: Bool = false
       var timeRemaining: Int = 0
       var timerEndDate: Date?

}
