// TODO: Move most of whats here to separate files

import SwiftUI

@Observable
class TodoListViewModel {
    @ObservationIgnored @AppStorage("highestTaskId") private var highestTaskId: Int = 0
    @ObservationIgnored @AppStorage("taskData") private var taskData: Data = Data()

    var tasks: [Int: Task] = [:]
    let toastManager: ToastManager
    
    init(toastManager: ToastManager) {
        self.toastManager = toastManager
        tasks = getTasksFromStorage()
    }

    private func getTasksFromStorage() -> [Int: Task] {
        if let tasks = try? JSONDecoder().decode([Int: Task].self, from: taskData) {
            return tasks
        }
        return [:] // If cannot decode, return none
    }
    
    private func saveTasksToStorage() {
        guard let encodedTasks = try? JSONEncoder().encode(tasks) else {
            toastManager.showToast(Toast.errorSavingToast)
            return
        }
        taskData = encodedTasks
        toastManager.showToast(Toast.successSavingToast)
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
            // TODO: Only call if values changed
            viewModel.updateTask(taskId: task.id, title: title, description: description)
        }
    }
}

struct Toast {
    let text: String
    let imageName: String
    let foregroundColor: Color
    
    init(text: String, imageName: String, foregroundColor: Color = Color(.systemBackground)) {
        self.text = text
        self.imageName = imageName
        self.foregroundColor = foregroundColor
    }
    
    static let errorSavingToast = Toast(text: "Error saving tasks!", imageName: "exclamationmark.triangle.fill", foregroundColor: .yellow)
    static let successSavingToast = Toast(text: "Tasks saved", imageName: "checkmark.square.fill")
}

@Observable
class ToastManager {
    var currentToast: Toast?
    
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
            // TODO: Fix toast colors in dark mode
            Label(toast.text, systemImage: toast.imageName)
                .padding()
                .background(.primary)
                .foregroundColor(toast.foregroundColor)
                .cornerRadius(8)
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

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
                TaskComposer()
            }
            if let toast = toastManager.currentToast {
                ToastView(toast: toast)
            }
        }
        .environment(viewModel)
        .environment(toastManager)
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
    let toastManager = ToastManager()
    let viewModel = TodoListViewModel(toastManager: toastManager)
    TodoListView(viewModel: viewModel, toastManager: toastManager)
}

#Preview {
    ToastView(toast: Toast.errorSavingToast)
}

#Preview {
    ToastView(toast: Toast.successSavingToast)
}

extension String {
    func pluralized(for count: Int) -> String {
        return count == 1 ? self : self + "s"
    }
}

