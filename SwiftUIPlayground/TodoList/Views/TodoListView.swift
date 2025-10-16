import SwiftUI

struct TodoListViewInternal: View {
  let viewModel: TodoListViewModel
  let toastManager: ToastManager

  var body: some View {
    ZStack {
      VStack {
        List(viewModel.getSortedTasks()) { task in
          TaskCellView(task: task) {
            viewModel.deleteTask(task)
          }
        }
        .scrollDismissesKeyboard(.interactively)
        TaskComposerView()
          .navigationTitle("Todo List")
          .navigationDestination(for: TodoListTask.self) { task in
            TaskDetailView(task: task, viewModel: viewModel)
          }
      }
      if let toast = toastManager.currentToast {
        ToastView(toast: toast)
      }
    }
    .environment(toastManager)
    .environment(viewModel)
  }
}

struct TodoListView: ExampleView {
  let toastManager = ToastManager()

  var body: some View {
    TodoListViewInternal(
      viewModel: TodoListViewModel(toastManager: toastManager), toastManager: toastManager)
  }
}

#Preview {
  NavigationStack {
    TodoListView()
  }
}
