import SwiftUI

struct RowData: Identifiable {
    let id = UUID()
    var title: String
    var isPinned: Bool = false
}

struct SwipeableListExample: View {
    @State private var tasks = [
        RowData(title: "Buy groceries"),
        RowData(title: "Finish SwiftUI project"),
        RowData(title: "Call mom"),
        RowData(title: "Read a book")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    HStack {
                        Text(task.title)
                        if task.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    // Trailing swipe (right-to-left)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            delete(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            pin(task)
                        } label: {
                            Label("Pin", systemImage: "pin")
                        }
                        .tint(.yellow)
                    }
                    
                    // Leading swipe (left-to-right)
                    .swipeActions(edge: .leading) {
                        Button {
                            markDone(task)
                        } label: {
                            Label("Done", systemImage: "checkmark.circle")
                        }
                        .tint(.green)
                    }
                }
            }
            .navigationTitle("Tasks")
        }
    }
    
    private func delete(_ task: RowData) {
        tasks.removeAll { $0.id == task.id }
    }
    
    private func pin(_ task: RowData) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isPinned.toggle()
        }
    }
    
    private func markDone(_ task: RowData) {
        print("\(task.title) marked as done ✅")
    }
}

struct SwipeableListExample_Previews: PreviewProvider {
    static var previews: some View {
        SwipeableListExample()
    }
}

