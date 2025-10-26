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
    var associatedGoal: GoalItem?
    var associatedSubGoal: SubgoalItem? //unused
    
    //for Agregator Challanges
    var isAggregator: Bool = false
    var isSubChallange: Bool = false
    var associatedAggregatorID: UUID?
    var isRoutine: Bool = false
    
    //for timer
    var hasTimer: Bool = false
    var timerDuration: Int = 0
    var isTimerRunning: Bool = false
    var timeRemaining: Int = 0
    var timerEndDate: Date?
    
    //for active days
    var activeDays: Set<DayOfWeek> = []
    
    var activeDaysSummary: String {
        // Case 1: Active every day (empty set or all 7 days)
        if activeDays.isEmpty || activeDays.count == 7 {
            return "Every Day"
        }
        
        // Define standard sets for comparison
        let weekdays: Set<DayOfWeek> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let weekends: Set<DayOfWeek> = [.saturday, .sunday]
        
        // Case 2: Active on weekdays
        if activeDays == weekdays {
            return "Weekdays"
        }
        
        // Case 3: Active on weekends
        if activeDays == weekends {
            return "Weekends"
        }
        
        // --- THIS IS THE UPDATED SECTION ---
        
        // Case 4: Custom days
        // Sort the days to show Monday first and Sunday last.
        let sortedDays = activeDays.sorted {
            // Rule 1: If $1 is Sunday and $0 is not, $0 comes first.
            if $1 == .sunday && $0 != .sunday { return true }
            
            // Rule 2: If $0 is Sunday and $1 is not, $0 comes last.
            if $0 == .sunday && $1 != .sunday { return false }
            
            // Rule 3: If neither is Sunday, sort by their normal raw value.
            return $0.rawValue < $1.rawValue
        }
        
        // --- END OF UPDATE ---
        
        // Map them to their short names (e.g., "Mo")
        let dayNames = sortedDays.map { $0.shortName }
        
        // Join them with a comma
        return dayNames.joined(separator: ", ")
    }
}

enum DayOfWeek: Int, Codable, CaseIterable, Hashable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    /// Returns a short, 2-letter name for the day.
    var shortName: String {
        switch self {
        case .sunday: return "Su"
        case .monday: return "Mo"
        case .tuesday: return "Tu"
        case .wednesday: return "We"
        case .thursday: return "Th"
        case .friday: return "Fr"
        case .saturday: return "Sa"
        }
    }
}
