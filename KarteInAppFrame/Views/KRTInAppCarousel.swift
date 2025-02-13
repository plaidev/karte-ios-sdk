//
//  Copyright 2024 PLAID, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import KarteVariables

@available(iOS 14.0, *)
@MainActor
final class KRTInAppCarousel: UIView {
    private let key: String
    private let vm: InAppCarouselViewModel

    private var itemTapListener: InAppFrame.ItemTapListener?
    private var loadingTask: Task<Void, Error>?
    private var autoplayTimer: Timer?
    private lazy var collectionView = setupCollectionView()
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ParsedImageData> = createDataSource()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .lightGray
        indicator.hidesWhenStopped = true
        indicator.center = self.center
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    enum Section: Int {
        case main
    }

    init(for key: String, model: InAppCarouselModel,
         loadingDelegate: LoadingDelegate? = nil,
         itemTapListener: InAppFrame.ItemTapListener? = nil
    ) {
        self.key = key
        self.vm = InAppCarouselViewModel(model: model)
        self.vm.loadingDelegate = loadingDelegate
        self.itemTapListener = itemTapListener
        super.init(frame: .zero)

        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.vm.loadingDelegate?.didChangeLoadingState(to: .initialized)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        if subview is UIActivityIndicatorView {
            return
        }

        loadingTask = Task {
            collectionView.isHidden = true

            loadingIndicator.startAnimating()
            do {
                // NOTE: To prevent flickering loading indicator, wait for 300ms at least
                try await Task.sleep(nanoseconds: 300_000_000)
                try Task.checkCancellation()
                try await self.vm.loadContents()
                loadingIndicator.stopAnimating()
                try Task.checkCancellation()

                setupDataSource()
                collectionView.isHidden = false
                setupAutoplayTimerIfNeeded()

                let v = Variables.variable(forKey: key)
                if v.isDefined {
                    Tracker.trackOpen(variable: v)
                }
            } catch {
                Logger.warn(tag: .inAppFrame, message: "task is cancelled: \(error)")
                await self.vm.cancellLoadingState()
                self.isHidden = true
            }
        }
    }

    override public func didMoveToWindow() {
        if window == nil {
            self.vm.loadingDelegate = nil
            loadingTask?.cancel()
            resetAutoplayTimer()
        }
    }

    private func setupAutoplayTimerIfNeeded() {
        let autoplaySpeed = vm.getAutoplaySpeed()
        if autoplaySpeed > 0 {
            resetAutoplayTimer()
            autoplayTimer = Timer.scheduledTimer(withTimeInterval: autoplaySpeed, repeats: true) { [weak self] _ in
                guard let self = self else { return }

                // Find current index by getting the center of the content area
                Task {
                    let origin = await self.collectionView.frame.origin
                    let contentSize = await self.collectionView.contentSize
                    let contentCenter = CGPoint(x: contentSize.width / 2, y: origin.y + (contentSize.height / 2))
                    let lastIndex = await self.collectionView.numberOfItems(inSection: Section.main.rawValue) - 1
                    guard let ip = await self.collectionView.indexPathForItem(at: contentCenter) else {
                        return
                    }

                    let nextIndex = ip.item + 1
                    let i = nextIndex <= lastIndex ? nextIndex : 0
                    await self.collectionView.scrollToItem(at: .init(item: i, section: Section.main.rawValue), at: .centeredHorizontally, animated: true)
                }
            }
        }
    }

    private func resetAutoplayTimer() {
        if let timer = autoplayTimer {
            timer.invalidate()
            autoplayTimer = nil
        }
    }

    private func setupCollectionView() -> UICollectionView {
        let layout = createLayout()
        let cv = UICollectionView(frame: bounds, collectionViewLayout: layout)
        cv.alwaysBounceVertical = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }

    private func setupDataSource() {
        let layout = createLayout()
        collectionView.collectionViewLayout = layout

        var snapshot = NSDiffableDataSourceSnapshot<Section, ParsedImageData>()
        snapshot.appendSections([.main])
        snapshot.appendItems(vm.imageData, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let width = vm.getImageWidth()
        let height = vm.getImageHeidht()
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(width),
                                               heightDimension: .estimated(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = vm.getScrollBehaviour()

        let topMargin = vm.getTopMargin()
        let bottomMargin = vm.getBottomMargin()
        let startMargin = vm.getStartMargin()
        let endMargin = vm.getEndMargin()
        section.contentInsets = .init(top: topMargin, leading: startMargin, bottom: bottomMargin, trailing: endMargin)
        section.interGroupSpacing = vm.getItemSpacing()

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, ParsedImageData> {
        let v = Variables.variable(forKey: key)
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ParsedImageData> { cell, indexPath, _ in
            cell.contentConfiguration = CellConfiguration(
                variable: v,
                templateType: self.vm.templateType,
                width: self.vm.getImageWidth(),
                height: self.vm.getImageHeidht(),
                imageData: self.vm.imageData[indexPath.row],
                tapListener: self.itemTapListener,
                config: self.vm.model.config
            )
        }
        return UICollectionViewDiffableDataSource<Section, ParsedImageData>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    @available(iOS 14.0, *)
    private class KRTCarouselCell: UICollectionViewCell, UIContentView {
        static let reuseIdentifier = "KRTCarouselCell"

        let variable: Variable
        let templateType: InAppCarouselModel.TemplateType
        let width: CGFloat
        let height: CGFloat
        let tapListener: InAppFrame.ItemTapListener?

        var configuration: any UIContentConfiguration {
            didSet {
                guard let conf = configuration as? CellConfiguration else { return }
                setup(data: conf.imageData)
            }
        }

        private var radius: CGFloat {
            let radius = CGFloat((configuration as? CellConfiguration)?.config?.radius ?? 0)
            let shorterSide = min(width, height)
            return min(shorterSide / 2, radius)
        }

        init(variable: Variable, templateType: InAppCarouselModel.TemplateType, width: CGFloat, height: CGFloat,
             tapListener: InAppFrame.ItemTapListener?, configuration: some UIContentConfiguration
        ) {
            self.variable = variable
            self.templateType = templateType
            self.width = width
            self.height = height
            self.tapListener = tapListener
            self.configuration = configuration
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup(data: ParsedImageData) {
            let iv = UIImageView(frame: .zero)
            iv.image = data.image
            iv.clipsToBounds = true
            iv.contentMode = .scaleAspectFill
            iv.layer.cornerRadius = radius
            iv.translatesAutoresizingMaskIntoConstraints = false

            if let linkUrl = data.linkUrl {
                iv.isUserInteractionEnabled = true
                iv.addGestureRecognizer(
                    UrlLinkedTapGestureRecognizer(
                        target: self, action: #selector(imageTapped(_:)), index: data.index, linkUrl: linkUrl
                    )
                )
            }

            contentView.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                iv.topAnchor.constraint(equalTo: contentView.topAnchor),
                iv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                iv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

        @objc
        private func imageTapped(_ sender: UrlLinkedTapGestureRecognizer) {
            let consumeEvent = tapListener?(sender.linkUrl) ?? false
            if consumeEvent { return }

            if variable.isDefined {
                let values: [String: JSONConvertible] = [
                    "url": JSONConvertibleConverter.convert(sender.linkUrl.absoluteString),
                    "in_app_frame": [
                        "position_no": JSONConvertibleConverter.convert(sender.index),
                        "template_type": JSONConvertibleConverter.convert(templateType.rawValue)
                    ]
                ]
                Tracker.trackClick(variable: variable, values: values)
            }

            if UIApplication.shared.canOpenURL(sender.linkUrl) {
                UIApplication.shared.open(sender.linkUrl)
            }
        }

        private class UrlLinkedTapGestureRecognizer: UITapGestureRecognizer {
            let index: Int
            let linkUrl: URL

            init(target: AnyObject, action: Selector, index: Int, linkUrl: URL) {
                self.index = index
                self.linkUrl = linkUrl
                super.init(target: target, action: action)
            }
        }
    }

    @available(iOS 14.0, *)
    private struct CellConfiguration: UIContentConfiguration {
        let variable: Variable
        let templateType: InAppCarouselModel.TemplateType
        let width: CGFloat
        let height: CGFloat
        let imageData: ParsedImageData
        let tapListener: InAppFrame.ItemTapListener?
        let config: InAppCarouselModel.Config?

        func makeContentView() -> any UIView & UIContentView {
            KRTCarouselCell(variable: variable, templateType: templateType,
                            width: width, height: height, tapListener: tapListener, configuration: self)
        }

        func updated(for state: any UIConfigurationState) -> CellConfiguration {
            return self
        }
    }
}
