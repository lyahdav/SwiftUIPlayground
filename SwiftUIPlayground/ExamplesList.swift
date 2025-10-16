import SwiftUI

protocol ExampleView: View {
  init()
}

struct ExamplesList: View {
  private let examples: [any ExampleView.Type] = [
    TodoListView.self,
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
        createView(from: examples[index])
      }
    }
  }

  private func createView(from type: any ExampleView.Type) -> AnyView {
    return AnyView(type.init())
  }
}

#Preview {
  ExamplesList()
}
