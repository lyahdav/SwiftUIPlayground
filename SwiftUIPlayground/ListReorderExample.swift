import SwiftUI

struct RowView: View {
  @State private var counter = 0
  let name: String

  var body: some View {
    HStack {
      Text(name)
      Spacer()
      Button("Tap \(counter)") {
        counter += 1
      }
    }
  }
}

struct ListReorderExample: View {
  let withStableIds: Bool

  @State private var names = ["Alice", "Bob", "Charlie"]

  var body: some View {
    List {
      if withStableIds {
        // ✅ With stable id (uses String identity)
        ForEach(names, id: \.self) { name in
          RowView(name: name)
        }
        .onMove { from, to in
          names.move(fromOffsets: from, toOffset: to)
        }
      } else {
        // ❌ Without stable id (uses index)
        ForEach(Array(names.enumerated()), id: \.offset) { _, name in
          RowView(name: name)
        }
        .onMove { from, to in
          names.move(fromOffsets: from, toOffset: to)
        }
      }
    }
    .toolbar { EditButton() }
  }
}

struct ListReorderExampleWithStableIds: View {
  var body: some View {
    ListReorderExample(withStableIds: true)
  }
}

struct ListReorderExampleWithoutStableIds: View {
  var body: some View {
    ListReorderExample(withStableIds: false)
  }
}

#Preview {
  ListReorderExampleWithStableIds()
}
