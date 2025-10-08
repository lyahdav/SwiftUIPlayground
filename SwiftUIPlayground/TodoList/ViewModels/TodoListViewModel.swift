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
            tasks[highestTaskId] = Task(id: highestTaskId, title: newTaskTitle, description: "", createdAt: Date(), modifiedAt: Date())
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
            task.modifiedAt = Date()
            tasks[taskId] = task
            saveTasksToStorage()
        }
    }
    
    func getSortedTasks() -> [Task] {
        return tasks.values.sorted { $0.id < $1.id }
    }
}
