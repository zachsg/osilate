//
//  AppStorageSyncManager.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/17/25.
//

import WatchConnectivity
import SwiftUI

class AppStorageSyncManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = AppStorageSyncManager()
    private override init() { super.init(); activateSession() }
    
    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let maxHr = message[maxHrKey] as? Int {
            UserDefaults.standard.set(maxHr, forKey: maxHrKey)
        }
    }
    
    // Implement required delegate methods (can be empty if not used)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
