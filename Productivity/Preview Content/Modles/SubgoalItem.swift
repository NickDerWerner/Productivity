//
//  SubgoalItem.swift
//  Productivity
//
//  Created by Nick Werner on 15.09.25.
//

import SwiftUI

struct SubgoalItem: Identifiable, Codable{
    var id = UUID()
    var title: String
    var date: Date?
    var endDate: Date?
    var progress: Int?
    
}
