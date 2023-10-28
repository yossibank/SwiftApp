import Foundation

extension String {
    func snakecased() -> Self {
        var snakeCasedString = ""

        for char in self {
            if char.isUppercase {
                snakeCasedString += "_" + char.lowercased()
            } else {
                snakeCasedString += String(char)
            }
        }

        return snakeCasedString
    }
}
