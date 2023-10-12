//
//  SuggestCell.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/11.
//

import UIKit

class SuggestCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class var identifier: String {
        return String(describing: self)
    }

    var onArrowButtonTapped: (() -> Void)?

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel, arrowButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .appColor(.text1)
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.text1)
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()

    lazy var arrowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(AppImages.arrowUpLeft, for: .normal)
        button.tintColor = .appColor(.text1)
        button.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)
        return button
    }()

    func configure(title: String, image: UIImage?) {
        titleLabel.text = title
        iconImageView.image = image
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .appColor(.background)
        contentView.addSubview(stackView)
    }

    private func setupAutoLayout() {
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(Constants.padding)
        }
        arrowButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }

    @objc
    private func arrowButtonTapped() {
        onArrowButtonTapped?()
    }
}
