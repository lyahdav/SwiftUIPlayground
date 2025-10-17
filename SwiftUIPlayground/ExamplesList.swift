import SwiftUI

protocol CustomTitleConforming {
  var title: String { get }
}

struct ExamplesList: View {
  // Equivalent to:
  // private static func getTitle<V: View>(for view: V) -> String {
  private static func getTitle(for view: some View) -> String {
    if let customTitleConforming = view as? CustomTitleConforming {
      customTitleConforming.title
    } else {
      formatPascalCase(String(describing: type(of: view).self))
    }
  }

  private static func makeAnyView(view: some View) -> (AnyView, String) {
    return (AnyView(view), getTitle(for: view))
  }

  private let examples: [(view: AnyView, title: String)] = [
    makeAnyView(view: TodoListView()),
    makeAnyView(view: PaginationExample()),
    makeAnyView(view: BackgroundThreadProcessingExample()),
    makeAnyView(view: ListReorderExampleWithStableIds()),
    makeAnyView(view: ListReorderExampleWithoutStableIds()),
    makeAnyView(view: DeepNavigationExample()),
    makeAnyView(view: GitHubAPIExample()),
    makeAnyView(view: AsyncImageExampleView()),
  ]

  var body: some View {
    NavigationStack {
      List {
        ForEach(Array(examples.enumerated()), id: \.offset) { index, exampleType in
          NavigationLink(value: index) {
            Text(examples[index].title)
          }
        }
      }
      .navigationDestination(for: Int.self) { index in
        examples[index].view
      }
    }
  }

  static private func formatPascalCase(_ type: String) -> String {
    return type.replacingOccurrences(
      of: "([a-z])([A-Z])",
      with: "$1 $2",
      options: .regularExpression
    )
  }
}

#Preview {
  ExamplesList()
}
