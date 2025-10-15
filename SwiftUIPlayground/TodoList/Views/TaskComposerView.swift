import SwiftUI

struct TaskComposerView: View {
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
    }
}
