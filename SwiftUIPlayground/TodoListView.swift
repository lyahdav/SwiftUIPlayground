// TODO: Move most of whats here to separate files

import SwiftUI

@Observable
class TodoListViewModel {
    @ObservationIgnored @AppStorage("highestTaskId") private var highestTaskId: Int = 0
    @ObservationIgnored @AppStorage("taskData") private var taskData: Data = Data()
    
    var tasks: [Int: Task] = [:]

    init() {
        tasks = getTasksFromStorage()
    }

    private func getTasksFromStorage() -> [Int: Task] {
        if let tasks = try? JSONDecoder().decode([Int: Task].self, from: taskData) {
            return tasks
        }
        return [:] // If cannot decode, return none
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
    
    func addTask(newTaskTitle: String, numTasksToAdd: Int) {
        for _ in 0..<numTasksToAdd {
            tasks[highestTaskId] = Task(id: highestTaskId, title: newTaskTitle, description: "")
            highestTaskId += 1
            saveTasksToStorage()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeValue(forKey: task.id)
        saveTasksToStorage()
    }
    
    func updateTask(taskId: Int, title: String, description: String) {
        if var task = tasks[taskId] {
            task.title = title
            task.description = description
            tasks[taskId] = task
            saveTasksToStorage()
        }
    }
    
    func getSortedTasks() -> [Task] {
        return tasks.values.sorted { $0.id < $1.id }
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
            List(viewModel.getSortedTasks()) { task in
                TaskCellView(task: task) {
                    viewModel.deleteTask(task)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            TaskComposer()
        }
        .environment(viewModel)
    }
}

struct TaskComposer: View {
    @Environment(TodoListViewModel.self) private var viewModel
    @State private var newTaskTitle: String = ""
    @State private var numTasksToAdd: Int = 1

    var body: some View {
        HStack {
            TextField("New task", text: $newTaskTitle)
            let isTitleEmpty = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            Button("Add") {
                viewModel.addTask(newTaskTitle: newTaskTitle, numTasksToAdd: numTasksToAdd)
            }
            .disabled(isTitleEmpty)
            Picker("Choose a number", selection: $numTasksToAdd) {
                ForEach(1...10, id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 45)
            Text("time".pluralized(for: numTasksToAdd))
                .frame(maxWidth: 100)
        }
        .padding()
        .navigationTitle("Todo List")
        .navigationDestination(for: Task.self) { task in
            TaskDetailView(task: task)
        }
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

