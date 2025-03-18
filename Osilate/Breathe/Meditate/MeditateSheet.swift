//
//  MeditateSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct MeditateSheet: View {
    @AppStorage(meditateGoalKey) var meditateGoal: Int = meditateGoalDefault
        
    @Binding var showingSheet: Bool
    
    @State private var isTimed = true
    @State private var date: Date = .now
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Meditation details") {
                    Toggle(isOn: $isTimed) {
                        Text("Timed session?")
                    }
                    
                    if isTimed {
                        Stepper(value: $meditateGoal, in: 60...5400, step: 60) {
                            Label(
                                title: {
                                    HStack {
                                        Text("Goal:")
                                        Text(meditateGoal / 60, format: .number)
                                            .bold()
                                        Text("min")
                                    }
                                }, icon: {
                                    Image(systemName: isTimed ? meditateTimedSystemImage : meditateOpenSystemImage)
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Meditate")
            .onAppear {
                NotificationController.requestAuthorization()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        showingSheet.toggle()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Start") {
                        MeditatingView(isTimed: $isTimed, meditateGoal: $meditateGoal, date: $date, showingSheet: $showingSheet)
                    }
                }
            }
        }
    }
}

#Preview {
    MeditateSheet(showingSheet: .constant(true))
}
