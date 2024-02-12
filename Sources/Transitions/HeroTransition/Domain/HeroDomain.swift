import SwiftUI

internal class HeroDomain: ObservableObject {
    @Published var info: [HeroInfo] = []
}
