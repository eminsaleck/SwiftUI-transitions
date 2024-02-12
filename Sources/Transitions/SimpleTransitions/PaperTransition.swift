import SwiftUI

public struct PaperTransition: Transition {
    public var isBlurred: Bool
    
    public init(isBlurred: Bool = true) {
        self.isBlurred = isBlurred
    }
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
          .opacity(phase.isIdentity ? 1.0 : 0.0)
          .rotationEffect(phase.rotation)
          .offset(x: phase.offset)
          .blur(radius: isBlurred == true ? phase.blur : 0)
    }
}

fileprivate extension TransitionPhase {
    var blur: CGFloat {
        switch self {
        case .willAppear: return 3.5
        case .identity: return .zero
        case .didDisappear: return 59
        }
    }
    
    var offset: CGFloat {
        switch self {
        case .willAppear: return 500
        case .identity: return .zero
        case .didDisappear: return 500
        }
    }
    
    var ofsset: CGFloat {
        switch self {
        case .willAppear: return 500
        case .identity: return .zero
        case .didDisappear: return 500
        }
    }
    
    var rotation: Angle {
        switch self {
        case .willAppear: return .degrees(30)
        case .identity: return .zero
        case .didDisappear: return .degrees(-30)
        }
    }
}

