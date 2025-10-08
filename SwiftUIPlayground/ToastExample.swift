import SwiftUI

struct ToastExample: View {
    @State private var showToast = false

    var body: some View {
        ZStack {
            VStack {
                Button("Show Toast") {
                    withAnimation {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                        }
                    }
                }
            }

            if showToast {
                VStack {
                    Spacer()
                    Text("This is a toast!")
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}


#Preview {
    ToastExample()
}
