//
//  BreathDoneSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct BreathDoneSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(HealthController.self) private var healthController
    
    let date: Date
    let elapsed: TimeInterval
    
    @Binding var type: OBreathType
    @Binding var rounds: Int
    @Binding var showingSheet: Bool
    @Binding var showingMainSheet: Bool
    
    var body: some View {
        VStack {
            Text("Done \(type.rawValue.capitalized) Breathing")
                .font(.title)
                .padding(.bottom, 8)
            
            VStack {
                if rounds > 0 {
                    Text("You did \(rounds) \(rounds == 1 ? "round" : "rounds") of \(type.rawValue) breathing.")
                } else {
                    Text("You have to do at least 1 round to save your breath work.")
                }
            }
            .padding(.bottom, 12)
            
            HStack(alignment: .center) {
                Button("Cancel", role: .cancel) {
                    NotificationController.cancelAllPending()
                    
                    resetRounds()
                    
                    showingSheet.toggle()
                    showingMainSheet.toggle()
                }
                .padding()
                
                if rounds > 0 {
                    Button("Save") {
                        NotificationController.cancelAllPending()
                        
                        healthController.setMindfulMinutes(seconds: elapsed.secondsToMinutesRounded(), date: date)
                        
                        let breath: any OActivity = switch type {
                        case .four78:
                            O478Breath(date: date, duration: Int(elapsed.rounded()), rounds: rounds)
                        case .box:
                            OBoxBreath(date: date, duration: Int(elapsed.rounded()), rounds: rounds)
                        }

                        modelContext.insert(breath)
                        
                        resetRounds()
                        
                        showingSheet.toggle()
                        showingMainSheet.toggle()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private func resetRounds() {
        switch type {
        case .four78:
            if rounds < 4 {
                rounds = 4
            }
        case .box:
            if rounds < 20 {
                rounds = 20
            }
        }
    }
}

#Preview(traits: .sampleData) {
    BreathDoneSheet(date: .now, elapsed: 300.0, type: .constant(.four78), rounds: .constant(4), showingSheet: .constant(true), showingMainSheet: .constant(true))
        .environment(HealthController())
}
