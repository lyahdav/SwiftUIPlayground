import SwiftUI

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
            Text("Failed to load:\n\(error.localizedDescription)")
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
        }
        .padding()
    }
}

#Preview {
    ErrorView(error: AIError.invalidData, onRetry: {})
}
