import SwiftUI

// MARK: - Models

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let systemImage: String? // Optional SF Symbol for icon
}

struct QuickAccessItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let systemImage: String // SF Symbol for brand/placeholder
    let tint: Color
}

struct PastOrder: Identifiable, Hashable {
    let id = UUID()
    let restaurantName: String
    let rating: Double
    let reviewCountLabel: String // e.g., "8,000+"
    let distanceMiles: Double
    let etaMinutes: Int
    let imageName: String // Use asset name or URL in a real app
}

// MARK: - Sample Data

let sampleCategories: [Category] = [
    Category(name: "Grocery",     systemImage: "cart.fill"),
    Category(name: "Happy Hour",  systemImage: "clock"),
    Category(name: "Going Out",   systemImage: "figure.walk"),
    Category(name: "DashMart",    systemImage: "shippingbox.fill"),
    Category(name: "Flowers",     systemImage: "flower.fill"),
    Category(name: "Retail",      systemImage: "bag.fill")
]

let sampleQuickAccess: [QuickAccessItem] = [
    QuickAccessItem(title: "Crouching Tiger", systemImage: "fork.knife", tint: .orange),
    QuickAccessItem(title: "Marufuku Ramen",  systemImage: "leaf",       tint: .green),
    QuickAccessItem(title: "Favorites",       systemImage: "heart.fill", tint: .pink)
]

let sampleFoodFilters: [Category] = [
    Category(name: "Deals",     systemImage: "tag.fill"),
    Category(name: "Pizza",     systemImage: "takeoutbag.and.cup.and.straw.fill"),
    Category(name: "Healthy",   systemImage: "sparkles"),
    Category(name: "Sandwiches",systemImage: "sandwich")
]

let samplePastOrders: [PastOrder] = [
    PastOrder(restaurantName: "Marufuku Ramen",
              rating: 4.8,
              reviewCountLabel: "8,000+",
              distanceMiles: 1.2,
              etaMinutes: 26,
              imageName: "ramen_placeholder"),
    PastOrder(restaurantName: "Crouching Tiger",
              rating: 4.6,
              reviewCountLabel: "2,300+",
              distanceMiles: 0.9,
              etaMinutes: 22,
              imageName: "asian_placeholder")
]

// MARK: - Components

struct TopAddressSearchBar: View {
    let address: String
    @State private var query: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Address row
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundStyle(.red)
                Text(address)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "bell")
                    .foregroundStyle(.primary)
            }

            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search DoorDash", text: $query)
                    .textFieldStyle(.plain)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct CategoryChip: View {
    let label: String
    let systemImage: String?

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.medium)
            }
            Text(label)
                .font(.subheadline).bold()
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

struct CategoryRow: View {
    let title: String?
    let items: [Category]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.title3).bold()
                    .padding(.horizontal)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(items) { item in
                        CategoryChip(label: item.name, systemImage: item.systemImage)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct QuickAccessButton: View {
    let item: QuickAccessItem

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(item.tint.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: item.systemImage)
                    .foregroundStyle(item.tint)
            }
            Text(item.title)
                .font(.footnote)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 100)
    }
}

struct QuickAccessRow: View {
    let title: String
    let items: [QuickAccessItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3).bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        QuickAccessButton(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PromoBannerView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(colors: [.purple.opacity(0.85), .blue.opacity(0.85)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))

            VStack(alignment: .leading, spacing: 8) {
                Text("Save 25% or more on Happy Hour restaurants")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Every day from 2 – 5 pm")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))

                Button {
                    // Action
                } label: {
                    Text("Browse Now")
                        .font(.subheadline).bold()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.white)
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
                .padding(.top, 6)
            }
            .padding(16)
        }
        .frame(height: 140)
        .padding(.horizontal)
    }
}

struct RatingRow: View {
    let rating: Double
    let reviewCountLabel: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(String(format: "%.1f", rating))
                .font(.subheadline).bold()
            Text("(\(reviewCountLabel))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct MetaRow: View {
    let distanceMiles: Double
    let etaMinutes: Int

    var body: some View {
        HStack(spacing: 8) {
            Label(String(format: "%.1f mi", distanceMiles), systemImage: "mappin.and.ellipse")
                .labelStyle(.iconOnly)
            Text(String(format: "%.1f mi • %d min", distanceMiles, etaMinutes))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct PastOrderCard: View {
    let order: PastOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Image placeholder (replace with AsyncImage or real asset)
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray5))
                Image(systemName: "photo")
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 160)
            .overlay(alignment: .topLeading) {
                // Optional overlay tag or badge
                EmptyView()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Title
            Text(order.restaurantName)
                .font(.headline)

            // Rating + Reviews
            RatingRow(rating: order.rating, reviewCountLabel: order.reviewCountLabel)

            // Distance + ETA
            MetaRow(distanceMiles: order.distanceMiles, etaMinutes: order.etaMinutes)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TopAddressSearchBar(address: "1589 Carole Way")

                // Top category chips
                CategoryRow(title: nil, items: sampleCategories)

                // "What can we get you?" quick access
                QuickAccessRow(title: "What can we get you?", items: sampleQuickAccess)

                // Food filters row (Deals, Pizza, Healthy, Sandwiches)
                CategoryRow(title: nil, items: sampleFoodFilters)

                // Promo Banner
                PromoBannerView()

                // Past orders section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your past orders")
                        .font(.title2).bold()
                        .padding(.horizontal)

                    LazyVStack(spacing: 16) {
                        ForEach(samplePastOrders) { order in
                            PastOrderCard(order: order)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DoorDashView: View {
    var body: some View {
        NavigationStack {
            HomeView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("DoorDash")
                            .font(.headline)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Profile or cart
                        } label: {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                }
        }
    }
}

#Preview {
    DoorDashView()
        .environment(\.colorScheme, .light)
}
