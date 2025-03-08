//
//  MeditationDoneSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct MeditationDoneSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(HealthController.self) private var healthController
    
    @Binding var isTimed: Bool
    @Binding var date: Date
    @Binding var elapsed: TimeInterval
    @Binding var goal: Int
    @Binding var showingSheet: Bool
    @Binding var showingAlert: Bool
    
    var body: some View {
        VStack {
            Text("Done Meditating")
                .font(.title)
                .padding(.bottom, 8)
            
            VStack {
                if elapsed < 30 {
                    Text("You meditated for less than 1 minute.")
                    Text("You have to do at least a minute to log it!")
                        .font(.footnote)
                } else if isTimed {
                    Text("You meditated for \(elapsed.secondsAsTimeRoundedToMinutes(units: .full))")
                    Text("(\((elapsed / Double(goal) * 100).rounded() / 100, format: .percent) of your goal)")
                } else {
                    Text("You meditated for \(elapsed.secondsAsTimeRoundedToMinutes(units: .full)).")
                }
            }
            .padding(.bottom, 12)
            
            HStack(alignment: .center) {
                Button("Cancel", role: .cancel) {
                    NotificationController.cancelAllPending()
                    
                    showingAlert.toggle()
                    showingSheet.toggle()
                }
                .padding()
                
                if elapsed > 30 {
                    Button("Save") {
                        NotificationController.cancelAllPending()
                        
                        healthController.setMindfulMinutes(seconds: elapsed.secondsToMinutesRounded(), date: date)
                        
                        let meditation = OMeditate(date: date, duration: elapsed.secondsToMinutesRounded())
                        
                        modelContext.insert(meditation)
                        
                        showingAlert.toggle()
                        showingSheet.toggle()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    let healthController = HealthController()
    
    return MeditationDoneSheet(isTimed: .constant(true), date: .constant(.now), elapsed: .constant(300.0), goal: .constant(500), showingSheet: .constant(true), showingAlert: .constant(true))
        .environment(healthController)
}
