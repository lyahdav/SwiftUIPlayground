import SwiftUI

struct ProjectTask: Identifiable {
  let id = UUID()
  let name: String
  let priority: String
  let isCompleted: Bool
}

struct Project: Identifiable {
  let id = UUID()
  var title: String
  let tasks: [ProjectTask]
}

struct DeepNavigationExample: View {
  @State private var projects = [
    "Mobile App Development", "Website Redesign", "Marketing Campaign",
  ].map {
    Project(title: $0, tasks: [])
  }

  var body: some View {
    List {
      ForEach($projects) { $project in
        NavigationLink(project.title) {
          ProjectDetailView(project: $project)
        }
      }
    }
    .navigationTitle("Deep Navigation")
  }
}

struct ProjectDetailView: View {
  @Binding var project: Project
  @State private var tasks: [ProjectTask] = []
  @State private var isLoading = true

  var body: some View {
    Group {
      if isLoading {
        VStack {
          ProgressView()
          Text("Loading project tasks...")
            .foregroundColor(.secondary)
        }
      } else {
        List(tasks) { task in
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(task.name)
                .font(.headline)
              Text(task.priority)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            Spacer()
            if task.isCompleted {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            }
          }
          .padding(.vertical, 2)
        }
      }
    }
    .navigationTitle(project.title)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(destination: ProjectEditView(project: $project)) {
          Text("Edit")
        }
      }
    }
    .task {
      await loadProjectTasks()
    }
  }

  private func loadProjectTasks() async {
    // Simulate network delay
    try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

    // Hard-coded sample data
    let sampleTasks: [ProjectTask] = [
      ProjectTask(name: "Design User Interface", priority: "High", isCompleted: false),
      ProjectTask(name: "Implement Authentication", priority: "High", isCompleted: true),
      ProjectTask(name: "Write Unit Tests", priority: "Medium", isCompleted: false),
      ProjectTask(name: "Setup CI/CD Pipeline", priority: "Medium", isCompleted: false),
      ProjectTask(name: "Code Review", priority: "Low", isCompleted: true),
      ProjectTask(name: "Documentation", priority: "Low", isCompleted: false),
    ]

    await MainActor.run {
      self.tasks = sampleTasks
      self.isLoading = false
    }
  }
}

struct ProjectEditView: View {
  @Binding var project: Project

  var body: some View {
    VStack {
      Text("Edit Project")
        .font(.title)
        .padding(.bottom, 8)
      VStack(alignment: .leading, spacing: 4) {
        TextField("Title", text: $project.title)
          .onChange(of: project.title) { _, newValue in
            if newValue.count > 30 {
              project.title = String(newValue.prefix(30))
            }
          }

        HStack {
          Text("\(project.title.count)/30")
            .font(.caption)
            .foregroundColor(project.title.count >= 30 ? .red : .secondary)

          Spacer()

          if project.title.count >= 30 {
            Text("Maximum length reached")
              .font(.caption)
              .foregroundColor(.red)
          }
        }
      }
      Spacer()
    }
    .navigationTitle("Edit")
  }
}

#Preview {
  NavigationStack {
    DeepNavigationExample()
  }
}
