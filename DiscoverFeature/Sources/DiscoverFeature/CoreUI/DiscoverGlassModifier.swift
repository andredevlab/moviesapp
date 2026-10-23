import SwiftUI

struct DiscoverGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(DiscoverStyle.surface(for: colorScheme), in: Capsule())
        } else if #available(iOS 26, macOS 26, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            content.background(.regularMaterial, in: Capsule())
        }
    }
}

#if DEBUG
#Preview("Controle de vidro") {
    Button("Filtros", systemImage: "line.3.horizontal.decrease") {}
        .buttonStyle(.plain)
        .padding()
        .modifier(DiscoverGlassModifier())
        .padding(40)
        .background(DiscoverStyle.background(for: .dark))
        .preferredColorScheme(.dark)
}
#endif
