//
//  GoalItem.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//

import SwiftUI

struct GoalItem: Identifiable, Codable{
    var id = UUID()
    var title: String
    var progress: Int = 0
    var description: String = ""
    var creationDate: Date
    var endDate: Date?
}
