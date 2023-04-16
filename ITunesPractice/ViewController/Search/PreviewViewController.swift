//
//  PreviewViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/1.
//

import SnapKit
import UIKit
import WebKit

// MARK: - PreviewViewControllerDatasource

protocol PreviewViewControllerDatasource: AnyObject {
    func url(_ previewViewController: PreviewViewController) -> URL?

    func title(_ previewViewController: PreviewViewController) -> String
}

// MARK: - PreviewViewController

class PreviewViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    weak var dataSource: PreviewViewControllerDatasource?

    // MARK: - Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = dataSource?.title(self) ?? ""
    }

    // MARK: Private

    private var viewModel: TrackDetailViewModel!

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private func setupUI() {
        view.backgroundColor = .black

        setupLayout()
    }

    private func setupLayout() {
        webView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func loadURL() {
        guard let url = dataSource?.url(self),
              UIApplication.shared.canOpenURL(url)
        else {
            return
        }
        webView.load(URLRequest(url: url))
        activityIndicator.startAnimating()
    }
}

// MARK: WKNavigationDelegate

extension PreviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
