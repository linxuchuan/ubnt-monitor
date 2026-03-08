import Foundation

extension String {
    func formattedDate(style: DateFormatter.Style = .short) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = inputFormatter.date(from: self) else {
            return self
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = style
        outputFormatter.timeStyle = .short
        return outputFormatter.string(from: date)
    }
    
    func formattedDateMedium() -> String {
        formattedDate(style: .medium)
    }
}
