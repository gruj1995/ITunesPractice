//
//  YTBaseBottomAlert.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import Combine
import UIKit

// MARK: - YTBaseBottomAlert

class YTBaseBottomAlert<VM: YTBaseBottomAlertViewModel>: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Lifecycle

    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()

        titleLabel.text = viewModel.title
        viewModel.fetchData()
        tableView.reloadData()
    }

    // MARK: Private

    let viewModel: YTBaseBottomAlertViewModel
    var cancellables: Set<AnyCancellable> = .init()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        stackView.axis = .horizontal
        return stackView
    }()

    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.gray2)
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .appColor(.text1)
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(AppImages.xmark, for: .normal)
        button.tintColor = .appColor(.text1)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: Setup

    func setupUI() {
        view.backgroundColor = .appColor(.background)
        view.addSubview(stackView)
        view.addSubview(separator)
        view.addSubview(tableView)
    }

    func setupLayout() {
        let padding = Constants.padding
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(padding)
        }
        closeButton.snp.makeConstraints {
            $0.width.equalTo(closeButton.snp.height)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(padding)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(padding)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }

    @objc
    private func closeButtonTapped() {
        dismiss(animated: true)
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.emptyView()
    }
}
