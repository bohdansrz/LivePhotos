//
//  LPHomeRootView.swift
//  LivePhotos
//
//  Created by Office Mac on 1/12/20.
//  Copyright © 2020 Vinso. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LPHomeRootView: LPBaseView {
    
    @IBOutlet fileprivate weak var photosCollectionView: UICollectionView!
    
    private var _viewModel: LPHomeViewModelAble!
    private let _disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
}

// MARK: - Setup

private extension LPHomeRootView {
    
    func setupLayout() {
        backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
        
        setupPhotosCollection()
        setupActivityIndicator()
    }

    func setupPhotosCollection() {
        addSubview(photosCollectionView)
        photosCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        photosCollectionView.backgroundColor = backgroundColor
        photosCollectionView.register(nib: LPPhotoViewCell.self)
    }
    
    func setupActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setupSubscriptionsToViewModel() {
        _viewModel.isActivityIndicatorAnimation
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: _disposeBag)
        
        _viewModel.items
            .subscribe(onNext: { [weak self] _ in
                self?.photosCollectionView.reloadData()
            })
            .disposed(by: _disposeBag)
    }
    
}

// MARK: - Set

extension LPHomeRootView {
    
    func set(viewModel: LPHomeViewModelAble) {
        _viewModel = viewModel
        
        setupSubscriptionsToViewModel()
    }
    
}

// MARK: - UICollectionViewDataSource

extension LPHomeRootView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(LPPhotoViewCell.self, for: indexPath)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LPHomeRootView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let livePhoto = _viewModel.item(at: indexPath)
        guard let photoCell = cell as? LPPhotoViewCell else {
            assertionFailure("required")
            return
        }
        photoCell.livePhoto = livePhoto
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return _viewModel.kPagePadding
    }
    
}

// MARK: - UIScrollView

extension LPHomeRootView {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        contentOffset.x += photosCollectionView.bounds.width / 2
        guard let indexPath = photosCollectionView.indexPathForItem(at: contentOffset) else {
            return
        }
        photosCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let currentCell = photosCollectionView.visibleCells.first else {
            assertionFailure("required")
            return
        }
        guard let currentPhotoCell = currentCell as? LPPhotoViewCell else {
            assertionFailure("required")
            return
        }
        currentPhotoCell.hint()
    }
    
}
