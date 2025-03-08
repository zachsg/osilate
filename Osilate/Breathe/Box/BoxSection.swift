//
//  BoxSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct BoxSection: View {
    @Binding var rounds: Int

    var body: some View {
        Section {
            Stepper(value: $rounds, in: 20...75, step: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Rounds:")
                            
                            Text(rounds, format: .number)
                                .fontWeight(.bold)
                                .padding(.leading, 4)
                                .foregroundStyle(.accent)
                        }

                        Text("Equivalent to \(rounds * 16 / 60) minutes")
                            .font(.caption)
                    }
                }
            }
        }
       
        Section {
            BoxStepsSection()
            
            BoxLearnMoreSection()
        } header: {
            Label(learnLabel, systemImage: learnSystemImage)
        }
        .headerProminence(.increased)
    }
}

#Preview {
    BoxSection(rounds: .constant(40))
}

