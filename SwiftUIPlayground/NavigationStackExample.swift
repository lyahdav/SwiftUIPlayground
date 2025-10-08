import SwiftUI

struct RootView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("Root View")
                Button("Go to Detail") {
                    path.append("Detail")
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "Detail" {
                    DetailView(path: $path)
                }
            }
        }
    }
}

struct DetailView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            Text("Detail View")
            Button("Pop Back with Animation") {
                withAnimation {
                    path.removeLast()   // pops the current view
                }
            }
            Button("Pop Back without Animation") {
                path.removeLast()   // pops the current view
            }
        }
    }
}

#Preview {
    RootView()
}
