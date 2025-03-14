//
//  BodyMetricCalculations.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/13/25.
//

import Foundation

class BodyMetricCalculations {
    static func tempStats(controller: HealthController) -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 150.0
        
        var average = 0.0
        for (_, temp) in controller.bodyTempByDay {
            average += temp
            
            if temp < measuredBottom {
                measuredBottom = temp
            }
            
            if temp > measuredTop {
                measuredTop = temp
            }
        }
        
        average /= Double(controller.bodyTempByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if controller.bodyTempToday < measuredBottom {
            .low
        } else if controller.bodyTempToday > measuredTop {
            .high
        } else {
            .normal
        }
        
        if !controller.hasBodyTempToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    static func hrvStats(controller: HealthController) -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 250.0
        
        var average = 0.0
        for (_, hrv) in controller.hrvByDay {
            average += hrv
            
            if hrv < measuredBottom {
                measuredBottom = hrv
            }
            
            if hrv > measuredTop {
                measuredTop = hrv
            }
        }
        
        average /= Double(controller.hrvByDay.count)
        
        rangeBottom = average - 10
        rangeTop = average + 10
        
        var status: BodyMetricStatus = if controller.hrvToday < measuredBottom {
            .low
        } else if controller.hrvToday > measuredTop {
            .high
        } else {
            .normal
        }
        
        if !controller.hasHrvToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    static func oxygenStats(controller: HealthController) -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 110.0
        
        var average = 0.0
        for (_, oxygen) in controller.oxygenByDay {
            average += oxygen
            
            if oxygen < measuredBottom {
                measuredBottom = oxygen
            }
            
            if oxygen > measuredTop {
                measuredTop = oxygen
            }
        }
        
        average /= Double(controller.oxygenByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if controller.oxygenToday < measuredBottom {
            .low
        } else if controller.oxygenToday > measuredTop {
            .high
        } else {
            .normal
        }
        
        if !controller.hasOxygenToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    static func respirationStats(controller: HealthController) -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 110.0
        
        var average = 0.0
        for (_, respiration) in controller.respirationByDay {
            average += respiration
            
            if respiration < measuredBottom {
                measuredBottom = respiration
            }
            
            if respiration > measuredTop {
                measuredTop = respiration
            }
        }
        
        average /= Double(controller.respirationByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if controller.respirationToday < measuredBottom {
            .low
        } else if controller.respirationToday > measuredTop {
            .high
        } else {
            .normal
        }
        
        if !controller.hasRespirationToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    static func rhrStats(controller: HealthController) -> (rangeTop: Int, rangeBottom: Int, measuredTop: Int, measuredBottom: Int, status: BodyMetricStatus) {
        var rangeTop: Int = 0
        var rangeBottom: Int = 0
        var measuredTop: Int = 0
        var measuredBottom: Int = 200
        
        var average = 0
        for (_, rhr) in controller.rhrByDay {
            average += rhr
            
            if rhr < measuredBottom {
                measuredBottom = rhr
            }
            
            if rhr > measuredTop {
                measuredTop = rhr
            }
        }
        
        average = Int((Double(average) / Double(controller.rhrByDay.count)).rounded(toPlaces: 0))
        
        rangeBottom = average - 3
        rangeTop = average + 3
        
        var status: BodyMetricStatus = if controller.rhrMostRecent < measuredBottom {
            .low
        } else if controller.rhrMostRecent > measuredTop {
            .high
        } else {
            .normal
        }
        
        if !controller.hasRhrToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    static func sleepStats(controller: HealthController) -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 24
        
        var average = 0.0
        for (_, sleep) in controller.sleepByDay {
            average += sleep
            
            if sleep < measuredBottom {
                measuredBottom = sleep
            }
            
            if sleep > measuredTop {
                measuredTop = sleep
            }
        }
        
        average /= Double(controller.sleepByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if controller.sleepToday < measuredBottom {
            .low
        } else if controller.sleepToday > measuredTop {
            .high
        } else {
            .normal
        }
        
        if !controller.hasSleepToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
}
