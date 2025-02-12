import CoreMotion
import HealthKit
import WatchKit

protocol MovementServiceDelegate: AnyObject {
    func didDetectShake()
}

class MovementService: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
    
    }
    
    // MARK: - Properties
    private let motionManager = CMMotionManager()
    private let shakeThreshold = 2.5
    private var lastShakeTime: Date?
    private let minShakeInterval = 1.0 // Prevent duplicate detections
    private var workoutSession: HKWorkoutSession?
    private let healthStore = HKHealthStore()
    
    // MARK: - Delegate
    weak var delegate: MovementServiceDelegate?

    // MARK: - Shake Detection
    private func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let acceleration = data?.acceleration else { return }
            
            let magnitude = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            )
            
            if magnitude > self.shakeThreshold && self.isValidShakeTime() {
                self.handleShakeDetection()
            }
        }
    }
    
    private func isValidShakeTime() -> Bool {
        guard let lastTime = lastShakeTime else { return true }
        return Date().timeIntervalSince(lastTime) > minShakeInterval
    }
    
    private func handleShakeDetection() {
        lastShakeTime = Date()
        
        // Notify delegate (UI) about the shake
        delegate?.didDetectShake()
        
        // Send shake event to API
        let timestamp = Date().timeIntervalSince1970
        ShakeAPINetworkManager.shared.sendShakeEvent(timestamp: timestamp)
    }
    
    // MARK: - Workout Session
    func startWorkout() {
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: HKWorkoutConfiguration())
            workoutSession?.delegate = self
            workoutSession?.startActivity(with: Date())
            startAccelerometerUpdates()
        } catch {
            print("Workout session failed: \(error.localizedDescription)")
        }
    }
    
    func stopWorkout() {
        workoutSession?.end()
        motionManager.stopAccelerometerUpdates()
    }
}
