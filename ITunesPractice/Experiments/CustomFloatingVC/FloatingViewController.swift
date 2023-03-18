//
//  FloatingViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/18.
//

import SnapKit
import UIKit

// 參考文章： https://medium.com/jeremy-xue-s-blog/swift-%E7%B0%A1%E5%96%AE%E5%8B%95%E6%89%8B%E5%81%9A%E4%B8%80%E5%80%8B%E6%87%B8%E6%B5%AE%E6%8B%96%E6%9B%B3%E8%A6%96%E7%AA%97-33ce429ca0f2

/// 可拖曳調整高度或關閉頁面
private class FloatingViewController: UIViewController {
    // MARK: Lifecycle

    init(contentVC: UIViewController) {
        self.contentVC = contentVC
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var cornerRadius: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // 位移懸浮視圖，將 floatingView 位移到視窗外
        floatingView.transform = CGAffineTransform(translationX: 0, y: floatingView.bounds.height)

        setGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 將懸浮視窗顯示在畫面上
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.6,
            delay: 0,
            options: [.curveEaseOut]) {
                self.view.backgroundColor = UIColor(white: 0, alpha: 0.8)
                self.floatingView.transform = .identity
            }
    }

    // MARK: Private

    private var contentVC: UIViewController

    private var animator: UIViewPropertyAnimator!

    private lazy var indicatorView: UIView = {
        let indicatorView = UIView()
        indicatorView.backgroundColor = .lightGray
        return indicatorView
    }() {
        didSet {
            indicatorView.layer.cornerRadius = indicatorView.bounds.height / 2
            indicatorView.layer.masksToBounds = true
        }
    }

    private lazy var floatingView: UIView = {
        let floatingView = UIView()
        return floatingView
    }() {
        didSet {
            floatingView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            floatingView.layer.cornerRadius = cornerRadius
            floatingView.layer.masksToBounds = true
        }
    }

    private func setupUI() {
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(floatingView)
        floatingView.snp.makeConstraints { make in
            make.centerX.width.height.equalToSuperview()
        }

        if let contentVCView = contentVC.view {
            floatingView.addSubview(contentVCView)
            contentVCView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        floatingView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(5)
        }
    }

    private func setGestures() {
        // 添加拖曳手勢
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(panOnFloatingView(_:)))
        floatingView.isUserInteractionEnabled = true
        floatingView.addGestureRecognizer(pan)
    }

    @objc
    private func panOnFloatingView(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // 拖曳開始時，創建 animator
            animator = UIViewPropertyAnimator(
                duration: 0.6,
                curve: .easeOut) {
                    let translationY = self.floatingView.bounds.height
                    self.floatingView.transform = CGAffineTransform(translationX: 0, y: translationY)
                    self.view.backgroundColor = .clear
                }
        case .changed:
            // 拖曳變化時，根據拖曳手勢的位移程度來調整整體動畫的完成百分比
            let translation = recognizer.translation(in: floatingView)
            let fractionComplete = translation.y / floatingView.bounds.height
            animator.fractionComplete = fractionComplete
        case .ended:
            // 拖曳結束時，根據其動畫完整百分比決定不同操作
            if animator.fractionComplete <= 0.5 {
                // 設定動畫器 isReversed 設為 true，用於反轉動畫
                animator.isReversed = true
            } else {
                // 添加動畫結束後的效果，關閉此控制器
                animator.addCompletion { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            }
            // 延續動畫
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
}
