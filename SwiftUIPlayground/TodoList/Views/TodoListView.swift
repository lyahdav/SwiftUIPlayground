import SwiftUI

struct TodoListView: View {
    let viewModel: TodoListViewModel
    let toastManager: ToastManager

    var body: some View {
        ZStack {
            NavigationStack {
                List(viewModel.getSortedTasks()) { task in
                    TaskCellView(task: task) {
                        viewModel.deleteTask(task)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                TaskComposerView()
            }
            if let toast = toastManager.currentToast {
                ToastView(toast: toast)
            }
        }
        .environment(viewModel)
        .environment(toastManager)
    }
}

#Preview {
    let toastManager = ToastManager()
    let viewModel = TodoListViewModel(toastManager: toastManager)
    TodoListView(viewModel: viewModel, toastManager: toastManager)
}
