import SwiftUI

@Observable
class ToastManager {
    var currentToast: Toast?
    
    init(currentToast: Toast? = nil) {
        self.currentToast = currentToast
    }
    
    func showToast(_ toast: Toast) {
        withAnimation {
            currentToast = toast
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { [weak self] in
                self?.currentToast = nil
            }
        }
    }
}

struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        VStack {
            Spacer()
            Label(toast.text, systemImage: toast.imageName)
                .padding()
                .background(.tertiary)
                .cornerRadius(8)
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    let toastManager = ToastManager(currentToast: Toast.errorSavingToast)
    let viewModel = TodoListViewModel(toastManager: toastManager)
    TodoListView(viewModel: viewModel, toastManager: toastManager)
}

#Preview {
    let toastManager = ToastManager(currentToast: Toast.successSavingToast)
    let viewModel = TodoListViewModel(toastManager: toastManager)
    TodoListView(viewModel: viewModel, toastManager: toastManager)
}
