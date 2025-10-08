import SwiftUI

struct TaskDetailView: View {
    @Environment(TodoListViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    let task: Task
    @State var title: String
    @State var description: String

    init(task: Task) {
        self.task = task
        title = task.title
        description = task.description
    }
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
            }
            Section(header: Text("Info")) {
                Text("ID: \(task.id)")
                Text("Created at: \(task.createdAt.formatted())")
                // TODO: Add last modified at
            }
        }
        Button("Delete") {
            viewModel.deleteTask(task)
            dismiss()
        }
        .navigationTitle("Task")
        .onDisappear {
            if title != task.title || description != task.description {
                viewModel.updateTask(taskId: task.id, title: title, description: description)
            }
        }
    }
}

#Preview {
    TaskDetailView(task: Task.exampleTask)
        .environment(TodoListViewModel(toastManager: ToastManager()))
}
