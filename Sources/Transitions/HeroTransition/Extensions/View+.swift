import SwiftUI

extension View {
    func onChange<Value: Equatable>(value: Value, completion: @escaping (Value) -> ()) -> some View {
        if #available(iOS 17, *) {
            return self
                .onChange(of: value) { oldValue, newValue in
                    completion(newValue)
                }
        } else {
            return self
                .onChange(of: value) { newValue in
                    completion(newValue)
                }
        }
    }
}

public extension View {
    @ViewBuilder
    func hero<Content: View>(
        id: String,
        animate: Binding<Bool>,
        sourceCornerRadius: CGFloat = 0,
        destinationCornerRadius: CGFloat = 0,
        @ViewBuilder content: @escaping () -> Content,
        completion: @escaping (Bool) -> ()
        
    ) -> some View {
        self
            .modifier(HeroLayerViewModifier(
                id: id,
                animate: animate,
                sourceCornerRadius: sourceCornerRadius,
                destinationCornerRadius: destinationCornerRadius,
                layer: content,
                completion: completion
            ))
    }
}
