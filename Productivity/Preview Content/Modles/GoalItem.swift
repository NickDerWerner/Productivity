//
//  GoalItem.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//

import SwiftUI

struct GoalItem: Identifiable, Codable, Equatable{
    var id = UUID()
    var title: String
    var progress: Int = 0
    var description: String = ""
    var creationDate: Date
    var endDate: Date?
    
    // 2. Füge diese Funktion hinzu
        static func == (lhs: GoalItem, rhs: GoalItem) -> Bool {
            return lhs.id == rhs.id
        }
}
