import SwiftUI

struct ContentView: View {
    @EnvironmentObject var movementService: MovementService
    
    var body: some View {
        VStack {
            Text("Shake Detection Active")
                .font(.caption)
                .foregroundColor(.green)
        }
    }
}
