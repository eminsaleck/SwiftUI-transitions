import SwiftUI

struct ContentView: View {
    
    @State private var colors: [Color] = [.black, .yellow, .purple, .brown]
    @State private var counter = 1
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    Swipe(direction: .trailing) {
                        CardView(color)
                    } actions: {
                        Action(tint: .blue, icon: "star.fill") {
                            print("bookmarked")
                        }
                        Action(tint: .red, icon: "trash.fill") {
                            withAnimation(.easeInOut) {
                                colors.removeAll(where: { $0 == color })
                            }
                        }
                    }
                }
            }
            .padding(15)
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder func CardView(_ color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 80, height: 3)
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 80, height: 3)
            }
            
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white.opacity(0.5))
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(color.gradient)
    }
}
