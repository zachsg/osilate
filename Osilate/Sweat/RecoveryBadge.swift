//
//  RecoveryBadge.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct RecoveryBadge: View {
    @Environment(HealthController.self) private var healthController

    var trend: ORecoveryTrend {
        let recoveryAverage = healthController.recoveryAverage
        let recoveryCurrent = healthController.recoveryMostRecent

        return recoveryCurrent.recoveryTrend(given: recoveryAverage)
    }

    var badgeParts: Text {
        let recoveryAverage = healthController.recoveryAverage
        let recoveryCurrent = healthController.recoveryMostRecent
        let trend = recoveryCurrent.recoveryTrend(given: recoveryAverage)

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

            if healthController.recoveryLoading {
                ProgressView()
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: progressSystemImage)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(trend == .improving ? .green : trend == .worsening ? .yellow : .accent)
                    .rotationEffect(.degrees(trend == .improving ? 45 : trend == .worsening ? 135 : 90))
            }
        }
        .foregroundStyle(.secondary)
        .font(.caption)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.recoveryMostRecent = 36
    healthController.recoveryAverage = 32
    healthController.latestRecovery = .now

    return RecoveryBadge()
        .environment(healthController)
}
