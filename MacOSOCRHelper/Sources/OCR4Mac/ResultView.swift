import SwiftUI

struct ResultView: View {
    @Binding var text: String
    var onClose: () -> Void

    @State private var showCopiedToast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("OCR Result")
                    .font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }

            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(4)

            HStack {
                if showCopiedToast {
                    Text("Copied!")
                        .foregroundColor(.green)
                        .font(.caption)
                        .transition(.opacity)
                }

                Spacer()

                Button("Copy") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(text, forType: .string)

                    withAnimation {
                        showCopiedToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showCopiedToast = false
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow))
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
