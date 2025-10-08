import SwiftUI

// MARK: - Model
@Observable
class CounterModel {
    var count: Int = 0
    
    func increment() {
        count += 1
    }
}

// MARK: - View
struct CounterView: View {
    // The view owns this instance
    @State private var model = CounterModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(model.count)")
                .font(.largeTitle)
            
            Button("Increment") {
                model.increment()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    CounterView()
}
