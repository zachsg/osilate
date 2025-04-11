//
//  Constants.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation

let showTodayKey = "showToday"
let showTodayDefault = false
let hourInSeconds = 60.0 * 60.0

let adjustTitle = "Make adjustments"
let adjustSystemImage = "gauge.with.dots.needle.bottom.50percent"
let aboutTitle = "About"
let infoTitle = "Info"
let infoSystemImage = "info.circle"

// MARK: Summary
let summaryString = "Summary"
let summarySystemImage = "house.circle"

// MARK: Health report
let healthReportTitle = "Health Report"
let healthReportSystemImage = "heart.text.clipboard.fill"
let inRangeSystemImage = "checkmark.square.fill"
let outRangeSystemImage = "exclamationmark.triangle.fill"
let optimalRangeSystemImage = "star.circle.fill"
let lowRangeSystemImage = "arrow.down.app.fill"
let highRangeSystemImage = "arrow.up.square.fill"
let missingRangeSystemImage = "questionmark.diamond.fill"
// Overall
let overallTitle = "Overall Today"
let overallSystemImage = "target"
// Body temp
let hasBodyTempKey = "hasBodyTemp"
let hasBodyTempDefault = true
let bodyTempTitle = "Body Temp"
let bodyTempLowSystemImage = "thermometer.low"
let bodyTempNormalSystemImage = "thermometer.medium"
let bodyTempHighSystemImage = "thermometer.high"
// Respiration
let hasRespirationKey = "hasRespiration"
let hasRespirationDefault = true
let respirationTitle = "Respiration Rate"
let respirationSystemImage = "lungs.fill"
// Oxygen / SpO2
let hasOxygenKey = "hasOxygen"
let hasOxygenDefault = true
let oxygenTitle = "Blood Oxygen"
let oxygenSystemImage = "drop.degreesign.fill"
// Resting Heart Rate
let hasRhrKey = "hasRhr"
let hasRhrDefault = true
let rhrTitle = "Resting Heart Rate"
let rhrSystemImage = "heart.fill"
// Heart rate variability
let hasHrvKey = "hasHrv"
let hasHrvDefault = true
let hrvTitle = "Heart Rate Variability"
let hrvSystemImage = "waveform.path"
// Sleep duration
let hasSleepKey = "hasSleep"
let hasSleepDefault = true
let sleepTitle = "Sleep Duration"
let sleepSystemImage = "bed.double.fill"

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
let maxHrKey = "maxHr"
let maxHrDefault = 185

// VO2 max
let vO2SystemImage = "stethoscope"
let vO2Units = "VO₂max"

// Heart
let heartUnits = "bpm"
let heartSystemImage = "heart"
let cardioRecoverySystemImage = "timer"

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
let statsSystemImage = "chart.bar"

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

let optionsSystemImage = "slider.horizontal.2.square"

let userAgeKey = "userAge"
let userAgeDefault = 30
let userGenderKey = "userGender"
let userGenderDefault: OGender = .female
let userSystemImage = "person.crop.circle"
