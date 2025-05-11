
import SwiftUI

extension View {
    
    func mySheet<Item, Content>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item : Identifiable, Content : View {
        return sheet(item: item, onDismiss: onDismiss) { identifiable in
            MYRootView {
                content(identifiable)
            }
        }
    }
    
    func mySheet<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content : View {
        sheet(isPresented: isPresented, onDismiss: onDismiss) {
            MYRootView {
                content()
            }
        }
    }
}
