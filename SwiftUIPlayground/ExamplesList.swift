import SwiftUI

protocol ExampleView: View {
  init()
  var title: String? { get }
}

extension ExampleView {
  var title: String? {
    return nil
  }
}

struct ExamplesList: View {
  private let examples: [any ExampleView.Type] = [
    TodoListView.self,
    PaginationExample.self,
    BackgroundThreadProcessingExample.self,
    ListReorderExampleWithStableIds.self,
    ListReorderExampleWithoutStableIds.self,
    DeepNavigationExample.self,
    GitHubAPIExample.self,
  ]

  var body: some View {
    NavigationStack {
      List {
        ForEach(Array(examples.enumerated()), id: \.offset) { index, exampleType in
          NavigationLink(value: index) {
            Text(displayTitle(for: exampleType))
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

  private func displayTitle(for type: any ExampleView.Type) -> String {
    let exampleView = type.init()
    return exampleView.title ?? formatPascalCase(type)
  }

  private func formatPascalCase(_ type: any ExampleView.Type) -> String {
    let string = String(describing: type)
    return string.replacingOccurrences(
      of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
  }
}

#Preview {
  ExamplesList()
}
