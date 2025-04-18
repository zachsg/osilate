//
//  LocationEncoding.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/18/25.
//

import CoreLocation
import Foundation

// Custom struct to represent CLLocation data, conforming to Codable
struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let timestamp: Date
    
    // Initialize from a CLLocation object
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
    }
    
    // Convert back to a CLLocation object
    func toCLLocation() -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude,
            horizontalAccuracy: 0, // Default or estimated accuracy
            verticalAccuracy: 0,  // Default or estimated accuracy
            timestamp: timestamp
        )
    }
}

// Function to encode an array of CLLocation objects to JSON
func encodeLocations(_ locations: [CLLocation]) throws -> Data {
    let locationDataArray = locations.map { LocationData(from: $0) }
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(locationDataArray)
}

// Function to decode JSON data back to an array of CLLocation objects
func decodeLocations(from jsonData: Data) throws -> [CLLocation] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let locationDataArray = try decoder.decode([LocationData].self, from: jsonData)
    return locationDataArray.map { $0.toCLLocation() }
}
