import UIKit
import WebKit
import SafariServices

final class GameWebViewController: UIViewController {
    private let gameURL = URL(string: "https://dragonrajac.vusagaming.uk/play/")!
    private let toolURL = URL(string: "https://dragonrajac.vusagaming.uk/tool/")!
    private let bgColor = UIColor(red: 13 / 255, green: 18 / 255, blue: 27 / 255, alpha: 1)

    private var webView: WKWebView!

    private let loadingOverlay = UIView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()

    private let errorOverlay = UIView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        setupWebView()
        setupOverlays()
        setupQuickMenuGesture()
        loadGame()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = bgColor
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.delegate = self

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupOverlays() {
        // Loading overlay
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.backgroundColor = bgColor
        view.addSubview(loadingOverlay)
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor(red: 232 / 255, green: 93 / 255, blue: 36 / 255, alpha: 1)
        spinner.startAnimating()

        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.text = "Đang kết nối Học Viện Cassell..."
        loadingLabel.textColor = UIColor(white: 0.88, alpha: 1)
        loadingLabel.font = .systemFont(ofSize: 15, weight: .medium)
        loadingLabel.textAlignment = .center

        loadingOverlay.addSubview(spinner)
        loadingOverlay.addSubview(loadingLabel)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor, constant: -18),
            loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 14),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: loadingOverlay.leadingAnchor, constant: 24),
            loadingLabel.trailingAnchor.constraint(lessThanOrEqualTo: loadingOverlay.trailingAnchor, constant: -24)
        ])

        // Error overlay
        errorOverlay.translatesAutoresizingMaskIntoConstraints = false
        errorOverlay.backgroundColor = bgColor
        errorOverlay.isHidden = true
        view.addSubview(errorOverlay)
        NSLayoutConstraint.activate([
            errorOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            errorOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = "Không thể kết nối tới máy chủ trò chơi.\nVui lòng kiểm tra mạng và thử lại."
        errorLabel.textColor = UIColor(white: 0.9, alpha: 1)
        errorLabel.font = .systemFont(ofSize: 15, weight: .regular)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Thử lại", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        retryButton.backgroundColor = UIColor(red: 232 / 255, green: 93 / 255, blue: 36 / 255, alpha: 1)
        retryButton.layer.cornerRadius = 10
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 28, bottom: 10, right: 28)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        errorOverlay.addSubview(errorLabel)
        errorOverlay.addSubview(retryButton)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: errorOverlay.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorOverlay.centerYAnchor, constant: -24),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: errorOverlay.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: errorOverlay.trailingAnchor, constant: -32),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: errorOverlay.centerXAnchor)
        ])
    }

    private func setupQuickMenuGesture() {
        let threeFingerTap = UITapGestureRecognizer(target: self, action: #selector(showQuickMenu))
        threeFingerTap.numberOfTouchesRequired = 3
        threeFingerTap.cancelsTouchesInView = false
        view.addGestureRecognizer(threeFingerTap)
    }

    private func loadGame() {
        errorOverlay.isHidden = true
        loadingOverlay.isHidden = false
        spinner.startAnimating()
        let request = URLRequest(url: gameURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(request)
    }

    @objc private func retryTapped() {
        loadGame()
    }

    @objc private func showQuickMenu() {
        let sheet = UIAlertController(
            title: "Long Tộc: Cổng Cassell",
            message: "Menu nhanh (chạm 3 ngón tay để mở)",
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: "Tải lại trang", style: .default) { [weak self] _ in
            self?.webView.reload()
        })
        sheet.addAction(UIAlertAction(title: "Về trang chủ game", style: .default) { [weak self] _ in
            self?.loadGame()
        })
        sheet.addAction(UIAlertAction(title: "Mở Công cụ (/tool/)", style: .default) { [weak self] _ in
            guard let self else { return }
            self.presentInAppSafari(url: self.toolURL)
        })
        sheet.addAction(UIAlertAction(title: "Xóa bộ nhớ đệm (Cache)", style: .destructive) { [weak self] _ in
            let types: Set<String> = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]
            WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast) {
                self?.loadGame()
            }
        })
        sheet.addAction(UIAlertAction(title: "Đóng", style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(sheet, animated: true)
    }

    private func presentInAppSafari(url: URL) {
        let safari = SFSafariViewController(url: url)
        safari.preferredBarTintColor = bgColor
        safari.preferredControlTintColor = .white
        present(safari, animated: true)
    }
}

extension GameWebViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        nil
    }
}

extension GameWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingOverlay.isHidden = true
        errorOverlay.isHidden = true
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleLoadError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleLoadError(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let scheme = url.scheme?.lowercased() ?? ""
        if scheme != "http" && scheme != "https" && scheme != "about" && scheme != "blob" && scheme != "data" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        if let host = url.host?.lowercased(), host != "dragonrajac.vusagaming.uk",
           navigationAction.navigationType == .linkActivated {
            presentInAppSafari(url: url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    private func handleLoadError(_ error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }
        loadingOverlay.isHidden = true
        spinner.stopAnimating()
        if webView.url == nil {
            errorLabel.text = "Không thể tải trò chơi:\n\(error.localizedDescription)"
            errorOverlay.isHidden = false
        }
    }
}

extension GameWebViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            if url.host?.lowercased() == "dragonrajac.vusagaming.uk", url.path.hasPrefix("/play") {
                webView.load(URLRequest(url: url))
            } else {
                presentInAppSafari(url: url)
            }
        }
        return nil
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "Đồng ý", style: .default) { _ in completionHandler(true) })
        present(alert, animated: true)
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { $0.text = defaultText }
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        present(alert, animated: true)
    }
}
