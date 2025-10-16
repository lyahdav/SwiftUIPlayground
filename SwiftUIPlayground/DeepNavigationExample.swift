import SwiftUI

struct WishListItem: Identifiable {
  let id = UUID()
  let name: String
  let price: String
  let isPurchased: Bool
}

struct WishList: Identifiable, Hashable {
  let id = UUID()
  let title: String
  let items: [WishListItem]

  static func == (lhs: WishList, rhs: WishList) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct DeepNavigationExample: ExampleView {
  @State private var wishLists = ["Wish List 1", "Wish List 2", "Wish List 3"].map {
    WishList(title: $0, items: [])
  }

  var body: some View {
    List {
      ForEach(wishLists) { wishList in
        NavigationLink(value: wishList) {
          Text(wishList.title)
        }
      }
    }
    .navigationTitle("Deep Navigation")
    .navigationDestination(for: WishList.self) { wishList in
      WishListDetailView(wishList: wishList)
    }
  }
}

struct WishListDetailView: View {
  let wishList: WishList
  @State private var items: [WishListItem] = []
  @State private var isLoading = true

  var body: some View {
    Group {
      if isLoading {
        VStack {
          ProgressView()
          Text("Loading wishlist items...")
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        List(items) { item in
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(item.name)
                .font(.headline)
              Text(item.price)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            Spacer()
            if item.isPurchased {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            }
          }
          .padding(.vertical, 2)
        }
      }
    }
    .navigationTitle(wishList.title)
    .task {
      await loadWishListItems()
    }
  }

  private func loadWishListItems() async {
    // Simulate network delay
    try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

    // Hard-coded sample data
    let sampleItems: [WishListItem] = [
      WishListItem(name: "Wireless Headphones", price: "$199.99", isPurchased: false),
      WishListItem(name: "Coffee Maker", price: "$89.99", isPurchased: true),
      WishListItem(name: "Bluetooth Speaker", price: "$79.99", isPurchased: false),
      WishListItem(name: "Smart Watch", price: "$299.99", isPurchased: false),
      WishListItem(name: "Laptop Stand", price: "$49.99", isPurchased: true),
      WishListItem(name: "Desk Lamp", price: "$39.99", isPurchased: false),
    ]

    await MainActor.run {
      self.items = sampleItems
      self.isLoading = false
    }
  }
}

#Preview {
  NavigationStack {
    DeepNavigationExample()
  }
}
