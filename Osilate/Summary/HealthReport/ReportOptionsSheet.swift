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
    
    @Binding var sheetIsShowing: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Use body temperature", isOn: $hasBodyTemp)
                } header: {
                    HeaderLabel(title: bodyTempTitle, systemImage: bodyTempNormalSystemImage)
                }
                
                Section {
                    Toggle("Use respiration rate", isOn: $hasRespiration)
                } header: {
                    HeaderLabel(title: respirationTitle, systemImage: respirationSystemImage)
                }
                
                Section {
                    Toggle("Use blood oxygen", isOn: $hasOxygen)
                } header: {
                    HeaderLabel(title: oxygenTitle, systemImage: oxygenSystemImage)
                }
                
                Section {
                    Toggle("Use resting heart rate", isOn: $hasRhr)
                } header: {
                    HeaderLabel(title: rhrTitle, systemImage: rhrSystemImage)
                }
            }
            .navigationTitle("Metrics Options")
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
