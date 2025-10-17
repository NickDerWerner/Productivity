//
//  HalfRingProgressView.swift
//  Productivity
//
//  Created by Nick Werner on 16.10.25.
//

import SwiftUI

// MARK: - Halbkreis-Shapes/Views

/// zeichnet den oberen Halbkreis (von 180° nach 0°)
struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.maxY) // unten mittig
        var p = Path()
        p.addArc(center: center,
                 radius: r,
                 startAngle: .degrees(180),
                 endAngle: .degrees(0),
                 clockwise: false)
        return p
    }
}

/// Fortschritt im Halbkreis 0…1
struct HalfRingProgress: View {
    var progress: Double          // 0...1
    var lineWidth: CGFloat = 16

    var body: some View {
        ZStack {
            // Track
            SemiCircle()
                .stroke(Color.gray.opacity(0.2),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            // Progress
            SemiCircle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    LinearGradient(colors: [.blue, .green],
                                   startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .animation(.spring(), value: progress)

            // Prozent in der Mitte
            VStack {
                Spacer() // schiebt den Text in die Mitte des Halbkreises
                Text("\(Int(progress * 100))%")
                    .font(.title2).bold()
                Spacer().frame(height: lineWidth) // Abstand zum Bogen
            }
        }
        // Höhe ~ Radius; 140 wirkt gut, passe an
        .frame(height: 140)
    }
}

// MARK: - Card für die Home-Seite

struct HomeProgressCard: View {
    let done: Int
    let total: Int
    var title: String = "Daily Score"

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(done) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                
            HalfRingProgress(progress: progress)
                .padding(.top, -60)
            Text("\(done) / \(total) completed today")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, -4)
        }
       
    }
}
