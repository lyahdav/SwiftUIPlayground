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
    
    private func saveTasksToStorage() {
        // TODO: Show toast?
        print("Saving \(tasks.count) task(s) to storage...")
        guard let encodedTasks = try? JSONEncoder().encode(tasks) else {
            // TODO: Show error in UI
            print("Error saving tasks")
            return
        }
        taskData = encodedTasks
    }
    
    func addTask() {
        for _ in 0..<numTasksToAdd {
            tasks.append(Task(id: highestTaskId, title: newTaskTitle, description: ""))
            highestTaskId += 1
            saveTasksToStorage()
        }
    }
    
    func deleteTask(_ task: Task) {
        // TODO: Avoid O(n) operation
        tasks.removeAll { $0.id == task.id }
        saveTasksToStorage()
    }
    
    func updateTaskDescription(taskId: Int, with description: String) {
        // TODO: Avoid O(n)
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].description = description
            saveTasksToStorage()
        }
    }
}

struct Task: Identifiable, Codable, Hashable {
    var id: Int
    var title: String
    var description: String
}

struct TaskCellView: View {
    let task: Task
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(value: task) {
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
}

struct TaskDetailView: View {
    @Environment(TodoListViewModel.self) private var viewModel
    let task: Task
    @State var description: String
    
    var body: some View {
        VStack {
            TextField("Description", text: $description)
        }
        .navigationTitle(task.title)
        .onDisappear {
            viewModel.updateTaskDescription(taskId: task.id, with: self.description)
        }
    }
}

struct TodoListView: View {
    @State private var viewModel = TodoListViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.tasks) { task in
                TaskCellView(task: task) {
                    viewModel.deleteTask(task)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            // TODO: Extract view
            HStack {
                TextField("New task", text: $viewModel.newTaskTitle)
                // TODO: Disable button when TextField blank
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
            .navigationTitle("Todo List")
            .navigationDestination(for: Task.self) { task in
                TaskDetailView(task: task, description: task.description)
            }
        }
        .environment(viewModel)
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
