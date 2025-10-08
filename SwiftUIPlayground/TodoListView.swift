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
    
    func updateTask(taskId: Int, title: String, description: String) {
        // TODO: Avoid O(n)
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].title = title
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
    @State var title: String
    @State var description: String

    init(task: Task) {
        self.task = task
        title = task.title
        description = task.description
    }
    
    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .padding()
            TextField("Description", text: $description)
                .padding()
        }
        .navigationTitle("Task")
        .onDisappear {
            viewModel.updateTask(taskId: task.id, title: title, description: description)
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
                let isTitleEmpty = viewModel.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                Button("Add") {
                    viewModel.addTask()
                }
                .disabled(isTitleEmpty)
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
                TaskDetailView(task: task)
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

