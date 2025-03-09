//
//  Constants.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation

let showTodayKey = "showToday"
let showTodayDefault = false

// MARK: Summary
let summaryString = "Summary"
let summarySystemImage = "house.circle"

// MARK: Health report
let healthReportTitle = "Health Report"
let healthReportSystemImage = "stethoscope"
let inRangeSystemImage = "checkmark.square.fill"
let outRangeSystemImage = "exclamationmark.triangle.fill"
// Overall
let overallTitle = "Overall"
let overallSystemImage = "target"
// Body temp
let bodyTempTitle = "Body Temp"
let bodyTempLowSystemImage = "thermometer.low"
let bodyTempNormalSystemImage = "thermometer.medium"
let bodyTempHighSystemImage = "thermometer.high"

// MARK: Move
let moveString = "Move"
let moveSystemImage = "figure.walk.circle"
let stepsSystemImage = "figure.walk"

let dailyMoveGoalKey = "dailyStepsGoal"
let dailyMoveGoalDefault = 8000

// MARK: Sweat
let sweatString = "Sweat"
let sweatSystemImage = "drop.circle"

let dailySweatGoalKey = "dailyZone2Goal"
let dailySweatGoalDefault = 1200 // 20 minutes
let zone2MinKey = "zone2Threshold"
let zone2MinDefault = 136

// VO2 max
let vO2SystemImage = "heart"
let vO2Units = "VO₂max"

// Heart
let heartUnits = "bpm"

// MARK: Breathe
let breatheString = "Breathe"
let breatheSystemImage = "apple.meditate.circle"
let actionsSystemImage = "apple.meditate"
let arrowSystemImage = "arrowshape.up.fill"
let cancelSystemImage = "xmark.circle"
let cancelLabel = "Cancel"
let closeLabel = "Close"
let progressSystemImage = "location.north.circle.fill"
let discloseSystemImage = "chevron.forward.circle"
let awardSystemImage = "trophy.circle.fill"
let stepsLabel = "Step-by-step"
let resourcesLabel = "Resources"
let learnLabel = "Learn more"
let learnSystemImage = "graduationcap"
let timeSystemImage = "timer"
let streaksSystemImage = "trophy"
let meditateOpenSystemImage = "stopwatch"
let meditateTimedSystemImage = "alarm"
let meditateTitle = "Meditate"
let meditateSystemImage = "brain"
let breathSystemImage = "lungs"
let breathTypeKey = "breathType"
let breathTypeDefault: OBreathType = .four78
let noseSystemImage = "nose"
let mouthSystemImage = "mouth"
let historyTitle = "Historical"
let historySystemImage = "clock"
let statsTitle = "Stats"
let statsSystemImage = "chart.pie"

let dailyBreatheGoalKey = "mindfulnessGoal"
let dailyBreatheGoalDefault = 1200 // 20 minutes
let meditateGoalKey = "meditateGoal"
let meditateGoalDefault = 600 // 10 minutes
let four78RoundsKey = "four78Rounds"
let four78RoundsDefault = 6
let boxRoundsKey = "boxRounds"
let boxRoundsDefault = 40

// MARK: Settings
let settingsString = "Settings"
let settingsSystemImage = "gearshape"

let userAgeKey = "userAge"
let userAgeDefault = 30
let userGenderKey = "userGender"
let userGenderDefault: OGender = .female
let userSystemImage = "person.crop.circle"
