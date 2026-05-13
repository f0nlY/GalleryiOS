//
//  FavouritesViewController.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import UIKit
import Combine

final class FavouritesViewController: UIViewController {

    private let viewModel: FavouritesViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 2
        let itemWidth = (UIScreen.main.bounds.width - spacing * 2) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FavouritesCell.self, forCellWithReuseIdentifier: FavouritesCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favourites yet "
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    init(viewModel: FavouritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadFavourites()
    }

    private func setupUI() {
        title = "Favourites"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                self?.collectionView.reloadData()
                self?.emptyLabel.isHidden = !photos.isEmpty
            }
            .store(in: &cancellables)
    }
}

extension FavouritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavouritesCell.reuseIdentifier,
            for: indexPath
        ) as? FavouritesCell else {
            return UICollectionViewCell()
        }

        let photo = viewModel.photos[indexPath.item]
        cell.configure(with: photo, imagePublisher: viewModel.loadImage(from: photo.thumbURL))
        return cell
    }
}

extension FavouritesViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let remove = UIAction(
                title: "Remove from Favourites",
                image: UIImage(systemName: "heart.slash"),
                attributes: .destructive
            ) { _ in
                guard let self else { return }
                let photo = self.viewModel.photos[indexPath.item]
                self.viewModel.removeFromFavourites(id: photo.id)
            }
            return UIMenu(title: "", children: [remove])
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVM = DetailViewModel(
            photos: viewModel.photos,
            selectedIndex: indexPath.item,
            favouritesRepository: { [weak self] in
                self!.viewModel.favouritesRepository
            }(),
            imageCacheService: viewModel.imageCacheService
        )
        let detailVC = DetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


