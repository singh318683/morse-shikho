import SwiftUI
import WebKit

private let deckColor = UIColor(red: 0x16 / 255, green: 0x28 / 255, blue: 0x3F / 255, alpha: 1)

struct ContentView: View {
    var body: some View {
        MorseWebView()
            .ignoresSafeArea()
            .background(Color(deckColor))
            .preferredColorScheme(.dark) // white status bar text
    }
}

struct MorseWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default() // keeps lessons, stats and streak between launches

        // Native feel: no long-press link previews or copy menus
        let js = "var s=document.createElement('style');s.innerHTML='*{-webkit-touch-callout:none}';document.head.appendChild(s);"
        config.userContentController.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true))

        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = deckColor
        web.scrollView.backgroundColor = deckColor
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.allowsBackForwardNavigationGestures = false
        web.allowsLinkPreview = false
        web.navigationDelegate = context.coordinator
        #if DEBUG
        if #available(iOS 16.4, *) { web.isInspectable = true } // Safari > Develop menu on the Mac
        #endif

        // Works whether the web files were added as a "web" folder or as loose files
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web")
            ?? Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        // Open any tapped web link in Safari instead of inside the app
        func webView(_ webView: WKWebView,
                     decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if action.navigationType == .linkActivated,
               let url = action.request.url,
               url.scheme == "http" || url.scheme == "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
