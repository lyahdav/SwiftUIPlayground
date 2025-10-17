import SwiftUI

// MARK: - Model
struct Item: Identifiable {
  let id = UUID()
  var title: String
}

// MARK: - Parent
struct ListItemBindingExample: View {
  @State private var items: [Item] = [
    Item(title: "First"),
    Item(title: "Second"),
    Item(title: "Third"),
  ]

  var body: some View {
    NavigationStack {
      List {
        ForEach($items) { $item in
          NavigationLink {
            // Pass binding to the whole struct
            ListItemBindingChildView(item: $item)
          } label: {
            Text(item.title)
          }
        }
      }
      .navigationTitle("Items")
    }
  }
}

// MARK: - Child
struct ListItemBindingChildView: View {
  @Binding var item: Item

  var body: some View {
    Form {
      Section(header: Text("Edit Item")) {
        TextField("Title", text: $item.title)
      }
    }
    .navigationTitle("Detail")
  }
}

// MARK: - Entry
#Preview {
  ListItemBindingExample()
}
