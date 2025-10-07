//
//  AddGoalView.swift
//  Productivity
//
//  Created by Nick Werner on 14.09.25.
//

// In AddGoalView.swift
import SwiftUI

struct AddGoalView: View {
    // 1. Eine Referenz zum GoalManager, um Ziele hinzuzufügen
    @ObservedObject var goalManager: GoalManager
    
    // 2. State-Variablen für die Texteingabe
    @State private var title: String = ""
    @State private var description: String = ""
    
    // 3. Eine Möglichkeit, diese Ansicht wieder zu schließen
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title of the Goal", text: $title)
                TextField("Description (optional)", text: $description)
            }
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss() // Schließt das Sheet
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Füge das neue Ziel über den Manager hinzu
                        goalManager.addGoal(title: title, description: description)
                        dismiss() // Schließt das Sheet
                    }
                    .disabled(title.isEmpty) // Button ist deaktiviert, solange kein Titel da ist
                }
            }
        }
    }
}
