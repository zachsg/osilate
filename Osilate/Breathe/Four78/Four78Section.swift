//
//  Four78Section.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct Four78Section: View {
    @Binding var rounds: Int
    
    var body: some View {
        Section {
            Stepper(value: $rounds, in: 4...8) {
                HStack(spacing: 0) {
                    Text("Rounds:")
                    
                    Text(rounds, format: .number)
                        .fontWeight(.bold)
                        .padding(.leading, 4)
                        .foregroundStyle(.accent)
                }
            }
        }
        
        Section {
            Four78StepsSection()
            
            Four78LearnMoreSection()
        } header: {
            Label(learnLabel, systemImage: learnSystemImage)
        }
        .headerProminence(.increased)
    }
}

#Preview {
    Four78Section(rounds: .constant(4))
}
