import CoreMotion
import HealthKit
import WatchKit

class MovementService: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    // MARK: - Motion Detection Properties
    private let motionManager = CMMotionManager()
    private let shakeThreshold = 2.5
    private var lastShakeTime: Date?
    private let minShakeInterval = 1.0 // Prevent duplicate detections
    
    // MARK: - Workout Session Properties
    private var workoutSession: HKWorkoutSession?
    private let healthStore = HKHealthStore()
    private let workoutConfiguration = HKWorkoutConfiguration()
    
    // MARK: - Init & Setup
    override init() {
        super.init()
        workoutConfiguration.activityType = .other
        setupHealthKit()
    }
    
    private func setupHealthKit() {
        let typesToShare: Set<HKSampleType> = [.workoutType()]
        let typesToRead: Set<HKObjectType> = [.workoutType()]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if !success {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    // MARK: - Workout Control
    func startWorkout() {
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
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
                pow(acceleration.z, 2))
            
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
        let timestamp = Date().timeIntervalSince1970
        
        // Get watch identifier and send to API
        let watchID = WKInterfaceDevice.current().identifierForVendor?.uuidString ?? "unknown_device"
        ShakeAPINetworkManager.shared.sendShakeEvent(timestamp: timestamp)

    }
    
    // MARK: - HKWorkoutSessionDelegate
    func workoutSession(_ session: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session error: \(error.localizedDescription)")
    }
    
    func workoutSession(_ session: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        // Handle workout events if needed
    }
}
