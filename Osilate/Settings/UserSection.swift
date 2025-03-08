//
//  UserSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct UserSection: View {
    @AppStorage(userAgeKey) var userAge = userAgeDefault
    @AppStorage(userGenderKey) var userGender = userGenderDefault
    
    var body: some View {
        Section {
            Picker("Gender", selection: $userGender) {
                ForEach(OGender.allCases, id: \.self) { gender in
                    Text(gender.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            
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
        } header: {
            HStack {
                Image(systemName: userSystemImage)
                Text("Profile")
            }
        }
    }
}

#Preview {
    UserSection()
}
