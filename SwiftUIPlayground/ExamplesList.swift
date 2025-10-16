import SwiftUI

protocol ExampleView: View {
  init()
}

struct ExamplesList: View {
  private let examples: [any ExampleView.Type] = [
    WrappedTodoListView.self,
    PaginationExample.self,
    BackgroundThreadProcessingExample.self,
    ListReorderExampleWithStableIds.self,
    ListReorderExampleWithoutStableIds.self,
  ]

  var body: some View {
    NavigationStack {
      List {
        ForEach(Array(examples.enumerated()), id: \.offset) { index, exampleType in
          NavigationLink(value: index) {
            Text(String(describing: exampleType))
          }
        }
      }
      .navigationDestination(for: Int.self) { index in
        AnyView(examples[index].init())
      }
    }
  }
}

struct WrappedTodoListView: ExampleView {
  let toastManager = ToastManager()

  var body: some View {
    TodoListView(
      viewModel: TodoListViewModel(toastManager: toastManager), toastManager: toastManager)
  }
}

#Preview {
  ExamplesList()
}
