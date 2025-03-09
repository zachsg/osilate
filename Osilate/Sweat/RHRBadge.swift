//
//  RHRBadge.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct RHRBadge: View {
    @Environment(HealthController.self) private var healthController

    var trend: ORHRTrend {
        let rhrAverage = healthController.rhrAverage
        let rhrCurrent = healthController.rhrMostRecent

        return rhrCurrent.rhrTrend(given: rhrAverage)
    }

    var badgeParts: Text {
        let rhrAverage = healthController.rhrAverage
        let rhrCurrent = healthController.rhrMostRecent
        let trend = rhrCurrent.rhrTrend(given: rhrAverage)

        let main = Text(trend.rawValue.capitalized)

        return main
    }

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                badgeParts
                    .fontWeight(.bold)
                    .foregroundStyle(trend == .improving ? .green : trend == .worsening ? .yellow : .accent)
            }

            Image(systemName: progressSystemImage)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(trend == .improving ? .green : trend == .worsening ? .yellow : .accent)
                .rotationEffect(.degrees(trend == .improving ? 135 : trend == .worsening ? 45 : 90))
        }
        .foregroundStyle(.secondary)
        .font(.caption)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.rhrMostRecent = 58
    healthController.rhrAverage = 60
    healthController.latestRhr = .now

    return RHRBadge()
        .environment(healthController)
}
