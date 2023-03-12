//
//  TrackDetailViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/28.
//

import Combine
import Kingfisher
import UIKit

// MARK: - TrackDetailViewControllerDatasource

protocol TrackDetailViewControllerDatasource: AnyObject {
    func trackId(_ trackDetailViewController: TrackDetailViewController) -> Int?
}

// MARK: - TrackDetailViewController

class TrackDetailViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    weak var dataSource: TrackDetailViewControllerDatasource?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = TrackDetailViewModel(trackId: dataSource?.trackId(self))
        observe()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: Private

    private var viewModel: TrackDetailViewModel!

    private var cancellables: Set<AnyCancellable> = []

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        return scrollView
    }()

    private lazy var topBackgroundView: UIView = {
        let topBackgroundView = UIView()
        return topBackgroundView
    }()

    private lazy var boxView: UIView = {
        let boxView = UIView()
        boxView.layer.borderColor = UIColor.gray.cgColor
        boxView.layer.cornerRadius = 6
        boxView.clipsToBounds = true
        return boxView
    }()

    /// 專輯封面圖示
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .appColor(.red1)
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightText
        return label
    }()

    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackNameLabel, artistNameLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var previewStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            createPreviewButton(type: .artist),
            createPreviewButton(type: .album),
            createPreviewButton(type: .track)
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    private func observe() {
        viewModel.$track
            .receive(on: RunLoop.main)
            .sink { [weak self] track in
                guard let self = self, let track = track else { return }
                self.coverImageView.kf.setImage(with: track.getArtworkImageWithSize(size: .square800))
                self.trackNameLabel.text = track.trackName
                self.artistNameLabel.text = track.artistName
                self.dateLabel.text = track.releaseDateValue?.toString(dateFormat: "yyyy/MM/dd") ?? ""
            }.store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .black

        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.leading.trailing.equalToSuperview()
        }

        scrollView.addSubview(topBackgroundView)
        topBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalTo(view) // scrollView 寬度
        }

        topBackgroundView.addSubview(boxView)
        boxView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(boxView.snp.width).multipliedBy(1)
            make.top.bottom.centerX.equalToSuperview()
        }

        boxView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        scrollView.addSubview(trackInfoStackView)
        trackInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(topBackgroundView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(scrollView).multipliedBy(0.95)
        }

        scrollView.addSubview(previewStackView)
        previewStackView.snp.makeConstraints { make in
            make.top.equalTo(trackInfoStackView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(scrollView).multipliedBy(0.4)
            make.bottom.equalToSuperview().offset(-400) // scrollView 底部
        }
    }

    private func createPreviewButton(type: PreviewType) -> UIButton {
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        let button = UIButton()
        button.tag = type.rawValue
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)

        var config = UIButton.Configuration.filled()
        config.imagePadding = 10
        config.buttonSize = .small
        config.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        // 設置文字方法1
        config.attributedTitle = AttributedString(type.title, attributes: AttributeContainer([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)]))
        // 設置文字方法2
//        var title = AttributedString(type.title)
//        title.foregroundColor = .appColor(.red1)
//        title.font = .systemFont(ofSize: 15, weight: .semibold)
//        config.attributedTitle = title
        config.titleAlignment = .leading
        config.image = type.iconImage
        config.imagePlacement = .leading // 圖片位置
        config.baseBackgroundColor = .appColor(.gray1)
        config.baseForegroundColor = .appColor(.red1) // 圖片及文字顏色
        config.cornerStyle = .small
        button.configuration = config
        return button
    }

    @objc
    private func buttonAction(_ sender: UIButton) {
        viewModel.selectedPreviewType = PreviewType(rawValue: sender.tag)

        let vc = PreviewViewController()
        vc.dataSource = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UIScrollViewDelegate

extension TrackDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果 (scrollView 滾動距離) > (trackNameLabel 與 scrollView 頂端間距)，就顯示 navigation bar 的標題
        let spaceBetweenViewToOrigin = -scrollView.convert(.zero, to: trackNameLabel).y
        let showNavTitle = scrollView.contentOffset.y > spaceBetweenViewToOrigin
        navigationController?.navigationBar.topItem?.title = showNavTitle ? viewModel.track?.trackName : ""
        navigationController?.navigationBar.setNeedsLayout() // 修復 ios 16 標題文字更新後可能未顯示的bug
    }
}

// MARK: PreviewViewControllerDatasource

extension TrackDetailViewController: PreviewViewControllerDatasource {
    func url(_ previewViewController: PreviewViewController) -> URL? {
        guard let urlString = viewModel.urlString else {
            return nil
        }
        return URL(string: urlString)
    }

    func title(_ previewViewController: PreviewViewController) -> String {
        return viewModel.selectedPreviewType?.title ?? ""
    }
}
