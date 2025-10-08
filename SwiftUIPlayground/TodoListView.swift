// TODO: Push to GitHub repo
// TODO: Move most of whats here to separate files

import SwiftUI

@Observable
class TodoListViewModel {
    @ObservationIgnored @AppStorage("highestTaskId") private var highestTaskId: Int = 0
    @ObservationIgnored @AppStorage("taskData") private var taskData: Data = Data()
    
    var tasks: [Task] = []
    var newTaskTitle: String = ""
    var numTasksToAdd: Int = 1

    init() {
        tasks = getTasksFromStorage()
    }

    private func getTasksFromStorage() -> [Task] {
        if let tasks = try? JSONDecoder().decode([Task].self, from: taskData) {
            return tasks
        }
        return [] // If cannot decode, return empty list
    }
    
    private func saveTasksToStorage(_ tasks: [Task]) {
        print("Saving \(tasks.count) task(s) to storage...")
        guard let encodedTasks = try? JSONEncoder().encode(tasks) else {
            print("Error saving tasks")
            return
        }
        taskData = encodedTasks
    }
    
    func addTask() {
        for _ in 0..<numTasksToAdd {
            tasks.append(Task(id: highestTaskId, title: newTaskTitle, description: ""))
            highestTaskId += 1
            saveTasksToStorage(tasks)
        }
    }
    
    func deleteTask(_ task: Task) {
        // TODO: Avoid O(n) operation
        tasks.removeAll { $0.id == task.id }
        saveTasksToStorage(tasks)
    }
}

struct Task: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
}

struct TaskCellView: View {
    let task: Task
    let onDelete: () -> Void
    
    // TODO: Add tap to go to detail screen
    var body: some View {
        HStack {
            Text("\(task.id)")
            Text(task.title)
        }
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                onDelete()
            }
        }
    }
}

struct TodoListView: View {
    @State private var viewModel = TodoListViewModel()
    
    var body: some View {
        List(viewModel.tasks) { task in
            TaskCellView(task: task) {
                viewModel.deleteTask(task)
            }
        }
        HStack {
            // TODO: Handle keyboard avoiding
            // TODO: move text field up when kb visible
            TextField("New task", text: $viewModel.newTaskTitle)
            Button("Add") {
                viewModel.addTask()
            }
            Picker("Choose a number", selection: $viewModel.numTasksToAdd) {
                ForEach(1...10, id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 45)
            Text("time".pluralized(for: viewModel.numTasksToAdd))
                .frame(maxWidth: 100)
        }
        .padding()
    }
}

#Preview {
    TodoListView()
}

extension String {
    func pluralized(for count: Int) -> String {
        return count == 1 ? self : self + "s"
    }
}
