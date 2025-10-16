import SwiftUI

enum Screen {
  case todoList
  case paginationExample
  case backgroundThreadProcessingExample
  case listReorderExample
  case listReorderExampleWithoutStableIds
}

struct ExamplesList: View {
  var body: some View {
    NavigationStack {
      List {
        // TODO: Make this use enum directly, or have an array of SwiftUI View classes and use that to build list
        NavigationLink(value: Screen.todoList) {
          Text("TodoList")
        }
        NavigationLink(value: Screen.paginationExample) {
          Text("PaginationExample")
        }
        NavigationLink(value: Screen.backgroundThreadProcessingExample) {
          Text("BackgroundThreadProcessingExample")
        }
        NavigationLink(value: Screen.listReorderExample) {
          Text("ListReorderExample")
        }
        NavigationLink(value: Screen.listReorderExampleWithoutStableIds) {
          Text("ListReorderExampleWithoutStableIds")
        }
      }
      .navigationDestination(for: Screen.self) { screen in
        switch screen {
        case .todoList:
          WrappedTodoListView()
        case .paginationExample:
          PaginationExample()
        case .backgroundThreadProcessingExample:
          BackgroundThreadProcessingExample()
        case .listReorderExample:
          ListReorderExample(withStableIds: true)
        case .listReorderExampleWithoutStableIds:
          ListReorderExample(withStableIds: false)
        }
      }
    }
  }
}

struct WrappedTodoListView: View {
  let toastManager = ToastManager()

  var body: some View {
    TodoListView(viewModel: TodoListViewModel(toastManager: toastManager), toastManager: toastManager)
  }
}

#Preview {
  ExamplesList()
}
