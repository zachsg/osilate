//
//  ActivityCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftData
import SwiftUI

struct ActivityCard: View {
    var activity: any OActivity
    
    var activityCategory: (title: String, systemImage: String) {
        return switch activity {
        case is OMeditate:
            ("Meditate", meditateSystemImage)
        case is O478Breath, is OBoxBreath:
            ("Breathe", breathSystemImage)
        default:
            ("Unknown", "")
        }
    }
    
    var duration: Int {
        var d = 0
        
        if activity is OMeditate {
            if let meditate = activity as? OMeditate {
                d = meditate.duration
            }
        } else if activity is O478Breath {
            if let four78 = activity as? O478Breath {
                d = four78.duration
            }
        } else if activity is OBoxBreath {
            if let box = activity as? OBoxBreath {
                d = box.duration
            }
        }
        
        return d
    }
    
    var activityTitle: String {
        var title = ""
        
        if activity is OMeditate {
            title = "Meditated for"
        }
        else if activity is O478Breath {
            if let four78 = activity as? O478Breath {
                title = "\(four78.rounds) rounds of 4-7-8 breathing"
            }
        } else if activity is OBoxBreath {
            if let box = activity as? OBoxBreath {
                title = "\(box.rounds) rounds of box breathing"
            }
        } else {
            title = "Unkown"
        }
        
        return title
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    Image(systemName: activityCategory.systemImage)
                    Text(activityCategory.title)
                }
                .foregroundStyle(.accent)
                
                Spacer()
                
                Text(activity.date, format: activity.date.dateFormat())
                    .foregroundStyle(.tertiary)
            }
            .font(.footnote.bold())
            
            HStack {
                VStack(alignment: .leading) {
                    switch activity {
                    case is O478Breath, is OBoxBreath:
                        Text(activityTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    default:
                        Text("\(activityTitle) \(TimeInterval(duration).secondsAsTime(units: .full))")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
                .foregroundStyle(.primary)
            }
            .padding(.top, 4)
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Query var meditates: [OMeditate]
    ActivityCard(activity: meditates.first!)
}
