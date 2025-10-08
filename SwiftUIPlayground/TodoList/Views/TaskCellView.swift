import SwiftUI

struct TaskCellView: View {
    let task: Task
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(value: task) {
            HStack {
                Text(task.title)
            }
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    onDelete()
                }
            }
        }
    }
}

#Preview {
    TaskCellView(task: Task.exampleTask, onDelete: {})
}
