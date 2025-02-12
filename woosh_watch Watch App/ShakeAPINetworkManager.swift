//
//  ShakeAPINetworkManager.swift
//  woosh_watch Watch App
//
//  Created by Abdelmonem Shaker on 11/02/2025.
//

// MARK: - Direct API Calls from Watch
import Foundation
import WatchKit

class ShakeAPINetworkManager {
    static let shared = ShakeAPINetworkManager()
    private let apiURL = URL(string: "https://your-api-endpoint.com/shake-event")!
    
    // Get Watch's UUID (acts as device identifier)
    private var watchUUID: String {
        WKInterfaceDevice.current().identifierForVendor?.uuidString ?? "unknown"
    }

    func sendShakeEvent(timestamp: TimeInterval) {
        let payload: [String: Any] = [
            "event": "shake_detected",
            "timestamp": timestamp,
            "watch_id": watchUUID  // Include Apple ID/UUID
        ]
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("⚠️ Watch API Error: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("⚠️ Watch API Status Code: \(httpResponse.statusCode)")
            } else {
                print("✅ Shake event sent DIRECTLY from Watch!")
            }
        }.resume()
    }
}
