import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView {
                Text("Loading…")
            }
            .progressViewStyle(.circular)
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    LoadingView()
}
