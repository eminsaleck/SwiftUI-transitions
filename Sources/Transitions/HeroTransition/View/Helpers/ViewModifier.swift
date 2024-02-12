import SwiftUI

struct HeroLayerViewModifier<Layer: View>: ViewModifier {
    let id: String
    @Binding var animate: Bool
    var sourceCornerRadius: CGFloat
    var destinationCornerRadius: CGFloat
    
    @ViewBuilder var layer: Layer
    
    var completion: (Bool) -> ()
    
    @EnvironmentObject private var hero: HeroDomain
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !hero.info.contains(where: { $0.infoID == id }) {
                    hero.info.append(.init(id: id))
                }
            }
            .onChange(value: animate) { newValue in
                if let index = hero.info.firstIndex(where: { $0.infoID == id }) {
                    hero.info[index].isActive = true
                    hero.info[index].layerView = AnyView(layer)
                    hero.info[index].sCornerRadius = sourceCornerRadius
                    hero.info[index].dCornerRadius = destinationCornerRadius
                    hero.info[index].completion = completion
                    
                    
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
                                hero.info[index].animateView = true
                            }
                        }
                    } else {
                        hero.info[index].hideView = false
                        withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
                            hero.info[index].animateView = false
                        }
                    }
                }
            }
    }
}
