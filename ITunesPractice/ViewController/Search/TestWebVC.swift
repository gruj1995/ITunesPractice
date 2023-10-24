//
//  TestWebVC.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/18.
//

import UIKit
import WebKit

class TestWebVC: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRequest()
    }

    var url: URL?

    // MARK: Private

    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
//        webView.allowsBackForwardNavigationGestures = false
        return webView
    }()

    private func setupUI() {
        view.backgroundColor = .appColor(.background)
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func loadRequest() {
        guard let url, let request = try? URLRequest(url: url, method: .get) else {
            return
        }
        webView.load(request)
        webView.sizeToFit()
    }
}

// MARK: WKNavigationDelegate

extension TestWebVC: WKNavigationDelegate {
    /// 控制在使用 WKWebView 載入網頁時如何處理網頁請求，包括網頁的導航行為（例如點擊連結、提交表單等）
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 檢查導航動作的類型是否是通過用戶交互觸發的
        if navigationAction.navigationType == .linkActivated {
            // 獲取導航動作的 URL 並開啟外部網頁
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }

        // 允許導航請求
        decisionHandler(.allow)
    }
}
