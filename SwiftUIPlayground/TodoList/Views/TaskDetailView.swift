import SwiftUI

struct TaskDetailView: View {
    @Environment(TodoListViewModel.self) private var viewModel
    let task: Task
    @State var title: String
    @State var description: String

    init(task: Task) {
        self.task = task
        title = task.title
        description = task.description
    }
    
    var body: some View {
        // TODO: Add delete button
        // TODO: Add created at date/time
        Form {
            TextField("Title", text: $title)
            TextField("Description", text: $description, axis: .vertical)
            
        }
        .navigationTitle("Task")
        .onDisappear {
            if title != task.title || description != task.description {
                viewModel.updateTask(taskId: task.id, title: title, description: description)
            }
        }
    }
}
