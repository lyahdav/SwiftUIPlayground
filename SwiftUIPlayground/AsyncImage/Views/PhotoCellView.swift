import SwiftUI

struct PhotoCellView: View {
    let photo: Photo
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: photo.url)) { image in
                image
                    .resizable()
                    .clipShape(Circle())
            } placeholder: {
                Circle().fill(Color.secondary.opacity(0.3))
            }
            .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(photo.title).font(.headline)
                Text(photo.description).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            }
        }
    }
}

#Preview {
    PhotoCellView(photo: Photo.examplePhoto)
}
