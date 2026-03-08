import SwiftUI

extension View {
    func cardStyle(backgroundColor: Color = Color(.secondarySystemBackground)) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
    }
}
