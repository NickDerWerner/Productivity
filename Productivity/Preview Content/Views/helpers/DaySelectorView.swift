// DaySelectorView.swift
import SwiftUI

struct DaySelectorView: View {
    @Binding var activeDays: Set<DayOfWeek>
    
    /// Sorts the days to show Monday first and Sunday last.
    private var sortedDays: [DayOfWeek] {
        DayOfWeek.allCases.sorted {
            // Rule 1: If $1 is Sunday and $0 is not, $0 comes first.
            if $1 == .sunday && $0 != .sunday { return true }
            
            // Rule 2: If $0 is Sunday and $1 is not, $0 comes last.
            if $0 == .sunday && $1 != .sunday { return false }
            
            // Rule 3: If neither is Sunday, sort by their normal raw value.
            return $0.rawValue < $1.rawValue
        }
    }

    var body: some View {
        HStack(spacing: 8) { // Added spacing
            Spacer() // Pushes the circles to the center
            ForEach(sortedDays, id: \.self) { day in
                Text(day.shortName)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 38, height: 38)
                    .foregroundColor(activeDays.contains(day) ? .white : .primary)
                    .background(
                        Group { // Use Group to apply conditional background
                            if activeDays.contains(day) {
                                Circle().fill(Color.blue)
                            } else {
                                // Use a platform-standard gray
                                Circle().fill(Color(UIColor.systemGray5))
                            }
                        }
                    )
                    .clipShape(Circle()) // This isn't strictly needed but good practice
                    .onTapGesture {
                        // Toggle membership in the set
                        if activeDays.contains(day) {
                            activeDays.remove(day)
                        } else {
                            activeDays.insert(day)
                        }
                    }
            }
            Spacer() // Pushes the circles to the center
        }
        .padding(.vertical, 4) // Add a little vertical padding
    }
}
