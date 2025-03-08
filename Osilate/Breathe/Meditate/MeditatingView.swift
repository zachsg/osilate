//
//  MeditatingView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct MeditatingView: View {
    @Binding var isTimed: Bool
    @Binding var meditateGoal: Int
    @Binding var date: Date
    @Binding var showingSheet: Bool
    
    @State private var showingAlert = false
    @State private var elapsed: TimeInterval = 0
    
    var body: some View {
        VStack {
            TimerView(goal: $meditateGoal, showingAlert: $showingAlert, elapsed: $elapsed, isTimed: isTimed, notificationTitle: "Meditation Done", notificationSubtitle: "You completed your mediation goal.")
        }
        .navigationTitle("Meditating")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            date = .now
        }
        .sheet(isPresented: $showingAlert, content: {
            MeditationDoneSheet(isTimed: $isTimed, date: $date, elapsed: $elapsed, goal: $meditateGoal, showingSheet: $showingSheet, showingAlert: $showingAlert)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        })
    }
}

#Preview {
    MeditatingView(isTimed: .constant(true), meditateGoal: .constant(300), date: .constant(.now), showingSheet: .constant(true))
}
