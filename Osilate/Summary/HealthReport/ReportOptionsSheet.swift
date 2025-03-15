//
//  ReportOptionsSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/12/25.
//

import SwiftUI

struct ReportOptionsSheet: View {
    @AppStorage(hasBodyTempKey) var hasBodyTemp = hasBodyTempDefault
    @AppStorage(hasRespirationKey) var hasRespiration = hasRespirationDefault
    @AppStorage(hasOxygenKey) var hasOxygen = hasOxygenDefault
    @AppStorage(hasRhrKey) var hasRhr = hasRhrDefault
    @AppStorage(hasHrvKey) var hasHrv = hasHrvDefault
    @AppStorage(hasSleepKey) var hasSleep = hasSleepDefault

    @Binding var sheetIsShowing: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $hasBodyTemp) {
                        Label("Body temperature", systemImage: bodyTempNormalSystemImage)
                    }
                    
                    Toggle(isOn: $hasRespiration) {
                        Label("Respiration rate", systemImage: respirationSystemImage)
                    }
                    
                    Toggle(isOn: $hasOxygen) {
                        Label("Blood oxygen", systemImage: oxygenSystemImage)
                    }
                    
                    Toggle(isOn: $hasRhr) {
                        Label("Resting heart rate", systemImage: rhrSystemImage)
                    }
                    
                    Toggle(isOn: $hasHrv) {
                        Label("Heart rate variability", systemImage: hrvSystemImage)
                    }
                    
                    Toggle(isOn: $hasSleep) {
                        Label("Sleep duration", systemImage: sleepSystemImage)
                    }
                } footer: {
                    Text("Disable any categories you don't want to use or your wearable doesn't support.")
                }
            }
            .navigationTitle("Metrics Available")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        sheetIsShowing.toggle()
                    } label: {
                        Label {
                            Text(closeLabel)
                        } icon: {
                            Image(systemName: cancelSystemImage)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ReportOptionsSheet(sheetIsShowing: .constant(true))
}
