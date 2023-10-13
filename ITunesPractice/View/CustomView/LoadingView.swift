//
//  LoadingView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import UIKit

class LoadingView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }

    let backView = UIView()

    private func setView() {
        backView.backgroundColor = .clear
        self.backgroundColor = .clear
        let mainView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        mainView.center = self.center

        mainView.backgroundColor = .black
        mainView.alpha = 0.3

        mainView.layer.cornerRadius = 5
        self.addSubview(mainView)
        let actView = UIActivityIndicatorView(style: .large)
        actView.startAnimating()
        actView.color = .white
        actView.hidesWhenStopped = true
        actView.center = self.center
        self.addSubview(actView)
    }

    func setup(to view: UIView) {
        self.center = view.center
        backView.frame = view.bounds
        view.addSubview(backView)
        view.addSubview(self)
    }

    func removeView() {
        backView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
