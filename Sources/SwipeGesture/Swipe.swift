import SwiftUI

public struct Swipe<Content: View>: View {
    var cornerRadius: CGFloat
    var direction: SwipeDirection
    @ViewBuilder var content: Content
    @ActionBuilder var actions: [Action]
    
    let viewID = UUID()
    @Binding private var isEnabled: Bool

    public init(cornerRadius: CGFloat = 0,
                direction: SwipeDirection = .trailing,
                isEnabled: Binding<Bool> = .constant(true),
                @ViewBuilder content: () -> Content,
                @ActionBuilder actions: () -> [Action]) {
            self.cornerRadius = cornerRadius
            self.direction = direction
            self._isEnabled = isEnabled
            self.content = content()
            self.actions = actions()
        }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    content
                        .containerRelativeFrame(.horizontal)
                        .background {
                            if let firstAction = actions.first {
                                Rectangle()
                                    .fill(firstAction.tint)
                            }
                        }
                        .id(viewID)
                    
                    ActionButtons {
                        withAnimation(.snappy) {
                            proxy.scrollTo(viewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                        }
                    }
                }
                .visualEffect { content, geometryProxy in
                    content.offset(x: scrollOffset(geometryProxy))
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background {
                if let lastAction = actions.last {
                    Rectangle()
                        .fill(lastAction.tint)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
        }
        .allowsHitTesting(isEnabled)
    }
    
    @ViewBuilder
    public func ActionButtons(resetPosition: @escaping () -> Void) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(actions.count) * 100)
            .overlay(alignment: direction.alignment) {
                HStack(spacing: 0) {
                    ForEach(actions) { button in
                        Button(action: {
                            Task {
                                isEnabled = false
                                resetPosition()
                                try? await Task.sleep(for: .seconds(0.25))
                                button.action()
                                try? await Task.sleep(for: .seconds(0.1))
                                isEnabled = true
                            }
                        }, label: {
                            Image(systemName: button.icon)
                                .font(button.iconFont)
                                .foregroundStyle(button.iconTint)
                                .frame(width: 100)
                                .frame(maxHeight: .infinity)
                                .contentShape(.rect)
                        })
                        .buttonStyle(.plain)
                        .background(button.tint)
                    }
                }
            }
    }
    
    private func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        
        return direction == .trailing ? (minX > 0 ? -minX : 0) : (minX < 0 ? -minX : 0)
    }
}

public struct Action: Identifiable {
    private(set) public var id: UUID = .init()
    public let tint: Color
    public let icon: String
    public let iconFont: Font
    public let iconTint: Color
    public let isEnabled: Bool
    public let action: () -> Void
    
    public init(tint: Color,
                icon: String,
                iconFont: Font = .title,
                iconTint: Color = .white,
                isEnabled: Bool = true,
                action: @escaping () -> Void) {
        self.tint = tint
        self.icon = icon
        self.iconFont = iconFont
        self.iconTint = iconTint
        self.isEnabled = isEnabled
        self.action = action
    }
}

@resultBuilder
public struct ActionBuilder {
    public static func buildBlock(_ components: Action...) -> [Action] {
        return components
    }
}

public enum SwipeDirection {
    case leading
    case trailing
    
    public var alignment: Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}
