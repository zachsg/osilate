//
//  BreathSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct BreathSheet: View {
    @Binding var showingSheet: Bool
    
    @AppStorage(breathTypeKey) var breathType: OBreathType = breathTypeDefault
    @AppStorage(four78RoundsKey) var four78Rounds: Int = four78RoundsDefault
    @AppStorage(boxRoundsKey) var boxRounds: Int = boxRoundsDefault
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $breathType.animation(), label: Text("Breath type")) {
                        ForEach(OBreathType.allCases, id: \.self) { type in
                            switch(type) {
                            case .four78:
                                Text(OBreathType.four78.rawValue.capitalized)
                            case .box:
                                Text(OBreathType.box.rawValue.capitalized)
                            }
                        }
                    }
                    .tint(.accentColor)
                }  footer: {
                    if breathType == .four78 {
                        Four78Footer()
                    } else if breathType == .box {
                        BoxFooter()
                    }
                }
                
                if breathType == .four78 {
                    Four78Section(rounds: $four78Rounds)
                } else if breathType == .box {
                    BoxSection(rounds: $boxRounds)
                }
            }
            .navigationTitle(breatheString)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(cancelLabel, role: .cancel) {
                        showingSheet.toggle()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Start") {
                        if breathType == .four78 {
                            Four78ingView(type: $breathType, rounds: $four78Rounds, showingMainSheet: $showingSheet)
                        } else if breathType == .box {
                            BoxingView(type: $breathType, rounds: $boxRounds, showingMainSheet: $showingSheet)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    BreathSheet(showingSheet: .constant(false))
}

