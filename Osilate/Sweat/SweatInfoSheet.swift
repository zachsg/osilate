//
//  SweatInfoSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/17/25.
//

import SwiftUI

struct SweatInfoSheet: View {
    @AppStorage(userAgeKey) var userAge = userAgeDefault
    @AppStorage(maxHrKey) var maxHr = maxHrDefault
    
    @Binding var sheetIsShowing: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Sweat is the amount of time you've spent in a heart rate of zone 2 or higher.")
                } header: {
                    HeaderLabel(title: aboutTitle, systemImage: infoSystemImage)
                }
                
                Section {
                    DisclosureGroup {
                        Section {
                            Stepper(value: $userAge.animation(), in: 16...120, step: 1) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("Age")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(userAge, format: .number)
                                        .fontWeight(.bold)
                                    Text("yrs old")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            VStack {
                                Stepper(value: $maxHr.animation(), in: 120...230, step: 1) {
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("Maximum HR")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text((maxHr), format: .number)
                                            .fontWeight(.bold)
                                        Text("bpm")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Button("Auto-calculate max HR") {
                                    maxHr = 220 - userAge
                                }
                                .buttonStyle(.bordered)
                            }
                        } footer: {
                            Text("Auto-calculation of max heart rate is based on your age.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } label: {
                        Text("Edit maximum heart rate")
                    }
                } header: {
                    HeaderLabel(title: adjustTitle, systemImage: adjustSystemImage)
                }
                
                Section {
                    let gradient = Gradient(colors: [OZone.one.color(), OZone.two.color(), OZone.three.color(), OZone.four.color(), OZone.five.color()])
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("Zone 2:")
                            HStack(spacing: 1) {
                                Text(hrZone(.two, at: .start), format: .number)
                                Text("-")
                                Text(hrZone(.two, at: .end), format: .number)
                            }
                            .fontWeight(.bold)
                            Text("bpm")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("1x")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 8)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(4, 4)))
                        }
                        
                        Text("Starts at 60% of max")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("Earn 1 minute for every minute spent in zone 2.")
                            .font(.footnote)
                        
                        Gauge(value: 0.6) {}
                            .gaugeStyle(.accessoryLinear)
                            .tint(gradient)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("Zone 3:")
                            HStack(spacing: 1) {
                                Text(hrZone(.three, at: .start), format: .number)
                                Text("-")
                                Text(hrZone(.three, at: .end), format: .number)
                            }
                            .fontWeight(.bold)
                            Text("bpm")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("2x")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 8)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(4, 4)))
                        }
                        
                        Text("Starts at 70% of max")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("Earn 2 minutes for every minute spent in zone 3!")
                            .font(.footnote)
                        
                        Gauge(value: 0.7) {}
                            .gaugeStyle(.accessoryLinear)
                            .tint(gradient)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("Zone 4:")
                            HStack(spacing: 1) {
                                Text(hrZone(.four, at: .start), format: .number)
                                Text("-")
                                Text(hrZone(.four, at: .end), format: .number)
                            }
                            .fontWeight(.bold)
                            Text("bpm")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("3x")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 8)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(4, 4)))
                        }
                        
                        Text("Starts at 80% of max")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("Earn 3 minutes for every minute spent in zone 4!")
                            .font(.footnote)
                        
                        Gauge(value: 0.8) {}
                            .gaugeStyle(.accessoryLinear)
                            .tint(gradient)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("Zone 5:")
                            HStack(spacing: 1) {
                                Text(hrZone(.five, at: .start), format: .number)
                                Text("+")
                            }
                            .fontWeight(.bold)
                            Text("bpm")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("4x")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 8)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(4, 4)))
                        }
                        
                        Text("Starts at 90% of max")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("Earn 4 minutes for every minute spent in zone 5!")
                            .font(.footnote)
                        
                        Gauge(value: 0.9) {}
                            .gaugeStyle(.accessoryLinear)
                            .tint(gradient)
                    }
                } header: {
                    HeaderLabel(title: "HR Zones", systemImage: rhrSystemImage)
                }
            }
            .onChange(of: maxHr) { oldValue, newValue in
                AppStorageSyncManager.shared.sendMaxHrToWatch(newValue)
            }
            .navigationTitle("What's Sweat?")
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
    SweatInfoSheet(sheetIsShowing: .constant(true))
}
