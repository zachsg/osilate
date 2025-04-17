//
//  AppStorageSyncManager.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/17/25.
//

import SwiftUI
import WatchConnectivity

class AppStorageSyncManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = AppStorageSyncManager()
    private override init() { super.init(); activateSession() }
    
    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendMaxHrToWatch(_ value: Int) {
        if WCSession.default.isPaired && WCSession.default.isWatchAppInstalled {
            WCSession.default.sendMessage([maxHrKey: value], replyHandler: nil, errorHandler: nil)
        }
    }
    
    // Implement required delegate methods (can be empty if not used)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}
