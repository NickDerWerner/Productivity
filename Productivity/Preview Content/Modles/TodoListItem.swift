//
//  TodoListItem.swift
//  Productivity
//
//  Created by Nick Werner on 13.09.25.
//

import SwiftUI

struct TodoItem: Identifiable, Codable {
    var id = UUID()        // Unique identifier for each todo
    var title: String      // The todo text
    var isCompleted: Bool = false  // Whether it's done or not
}
