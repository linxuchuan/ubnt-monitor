import SwiftUI

struct InfoGrid: View {
    let items: [(label: String, value: String)]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(items, id: \.label) { item in
                InfoRow(label: item.label, value: item.value)
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    InfoGrid(items: [
        ("MAC Address", "aa:bb:cc:dd:ee:ff"),
        ("IP Address", "192.168.1.1"),
        ("Version", "7.5.187"),
        ("Product Line", "UniFi")
    ])
    .padding()
}
