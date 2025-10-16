import SwiftUI

struct BackgroundThreadProcessingExample: ExampleView {
  @State private var result: String = "Waiting…"
  @State private var isLoading = false

  var body: some View {
    VStack(spacing: 20) {
      Text(result)
        .font(.title)

      if isLoading {
        ProgressView()
      }

      Button("Run Slow Task") {
        Task {
          // Note this runs on main thread because SwiftUI View body is a @MainActor context
          await runSlowLogic()
        }
      }
    }
    .padding()
  }

  // MARK: - Async Logic

  func runSlowLogic() async {
    isLoading = true

    // Run heavy work off the main thread
    let value = await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .background).async {
        // Simulate slow work
        Thread.sleep(forTimeInterval: 2)
        continuation.resume(returning: "Finished heavy work ✅")
      }
    }

    // Back on main actor to update UI
    // Can also use Task { @MainActor in
    await MainActor.run {
      result = value
      isLoading = false
    }

  }
}

#Preview {
  BackgroundThreadProcessingExample()
}
