import SwiftUI

extension LinearGradient {
    static var breezGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "FFCC8E"), location: 0.23),
                .init(color: Color(hex: "7DC7FF"), location: 0.82)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var breezVerticalGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "FFCC8E"), location: 0.23),
                .init(color: Color(hex: "7DC7FF"), location: 0.82)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var primaryVerticalGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "FFCC8E"), location: 0.23),
                .init(color: Color(hex: "7DC7FF"), location: 0.82)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "FFCC8E"), location: 0.23),
                .init(color: Color(hex: "7DC7FF"), location: 0.82)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
