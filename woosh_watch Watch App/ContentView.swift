import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var movementService = MovementService()
    
    var body: some View {
        VStack {
            Text("Shake Detection Active")
                .font(.caption)
                .foregroundColor(.green)
        }
        .onAppear {
            movementService.startWorkout()
            movementService.delegate = WatchInterfaceController.shared
        }
    }
}

// MARK: - Watch Interface Controller
class WatchInterfaceController: WKInterfaceController, MovementServiceDelegate {
    static let shared = WatchInterfaceController()
    
    func didDetectShake() {
        DispatchQueue.main.async {
            self.presentAlert(
                withTitle: "Shake Detected",
                message: "A shake gesture was detected!",
                preferredStyle: .alert,
                actions: [
                    WKAlertAction(title: "OK", style: .default) {}
                ]
            )
        }
    }
}
