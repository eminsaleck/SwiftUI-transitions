import SwiftUI
import OSLog

public struct HeroWrapper<Content: View>: View {
    
    @ViewBuilder var content: Content
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var overlayWindow: PassthroughWindow?
    @StateObject private var hero: HeroDomain = HeroDomain()
    
    public init(content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .onChange(value: scenePhase) { newValue in
                if newValue == .active { addOverlayWindow() }
            }
            .environmentObject(hero)
    }
    
    private func addOverlayWindow() {
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene,
               scene.activationState == .foregroundActive,
               overlayWindow == nil {
                
                let window = PassthroughWindow(windowScene: windowScene)
                window.backgroundColor = .clear
                window.isUserInteractionEnabled = false
                window.isHidden = false
                
                let heroLayer = HeroLayerView().environmentObject(hero)
                let rootViewController = UIHostingController(rootView: heroLayer)
                rootViewController.view.frame = windowScene.screen.bounds
                rootViewController.view.backgroundColor = .clear
                
                window.rootViewController = rootViewController
                
                self.overlayWindow = window
                
            }
            
            if overlayWindow == nil {
                os_log("No Window SCENE found")
            }
        }
    }
}

private struct HeroLayerView: View {
    @EnvironmentObject private var hero: HeroDomain
    
    var body: some View {
        GeometryReader { proxy in
            ForEach($hero.info) { $info in
                ZStack {
                    if let sourceAnchor = info.sourceAnchor,
                       let destinationAnchor = info.destinationAnchor,
                       let layerView = info.layerView,
                       !info.hideView {
                        
                        let sRect = proxy[sourceAnchor]
                        let dRect = proxy[destinationAnchor]
                        let animateView = info.animateView
                        
                        let size = CGSize(width: animateView ? dRect.size.width : sRect.size.width,
                                          height: animateView ? dRect.size.height : sRect.size.height)
                        
                        let offset = CGSize(width: animateView ? dRect.minX : sRect.minX,
                                            height: animateView ? dRect.minY : sRect.minY)
                        
                        layerView
                            .frame(width: size.width, height: size.height)
                            .clipShape(.rect(cornerRadius: animateView ? info.dCornerRadius : info.sCornerRadius))
                            .offset(offset)
                            .transition(.identity)
                            .frame(minWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
                .onChange(value: info.animateView) { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        if !newValue {
                            
                            info.isActive = false
                            info.layerView = nil
                            info.sourceAnchor = nil
                            info.destinationAnchor = nil
                            info.sCornerRadius = 0
                            info.dCornerRadius = 0
                            
                            info.completion(false)
                        } else {
                            info.hideView = true
                            info.completion(true)
                        }
                    }
                }
            }
        }
    }
}


public struct SourceView<Content: View>: View {
    let id: String
    
    @EnvironmentObject private var hero: HeroDomain
    @ViewBuilder var content: Content
    
    
    public init(id: String, content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .opacity(opacity)
            .anchorPreference(key: AnchorKey.self, value: .bounds, transform: { anchor in
                if let index, hero.info[index].isActive {
                    return [id: anchor]
                }
                
                return [:]
            })
            .onPreferenceChange(AnchorKey.self, perform: { value in
                if let index, hero.info[index].isActive, hero.info[index].sourceAnchor == nil {
                    hero.info[index].sourceAnchor = value[id]
                }
            })
    }
    
    var index: Int? {
        if let index = hero.info.firstIndex(where: { $0.infoID == id }) {
            return index
        }
        
        return nil
    }
    
    var opacity: CGFloat {
        if let index {
            return hero.info[index].isActive ? 0 : 1
        }
        
        return 1
    }
}

public struct DestinationView<Content: View>: View {
    let id: String
    
    @EnvironmentObject private var hero: HeroDomain
    @ViewBuilder var content: Content
    
    public init(id: String, content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .opacity(opacity)
            .anchorPreference(key: AnchorKey.self, value: .bounds, transform: { anchor in
                if let index, hero.info[index].isActive {
                    return ["DESTINATION\(id)": anchor]
                }
                
                return [:]
            })
            .onPreferenceChange(AnchorKey.self, perform: { value in
                if let index, hero.info[index].isActive {
                    hero.info[index].destinationAnchor = value["DESTINATION\(id)"]
                }
            })
    }
    
    var index: Int? {
        if let index = hero.info.firstIndex(where: { $0.infoID == id }) {
            return index
        }
        
        return nil
    }
    
    var opacity: CGFloat {
        if let index {
            return hero.info[index].isActive ? (hero.info[index].hideView ? 1 : 0) : 1
        }
        
        return 1
    }
}

private class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}
