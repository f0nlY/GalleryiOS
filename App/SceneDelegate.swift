//
//  SceneDelegate.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootViewController()
        window.makeKeyAndVisible()
        self.window = window
    }

    private func makeRootViewController() -> UIViewController {
        let tabBar = UITabBarController()
        tabBar.tabBar.tintColor = .systemPink

        let networkService = NetworkService()
        let coreDataStack = CoreDataStack.shared
        let favouritesRepository = FavouritesRepository(coreDataStack: coreDataStack)
        let imageCacheService = ImageCacheService.shared

        let galleryVM = GalleryViewModel(
            networkService: networkService,
            favouritesRepository: favouritesRepository,
            imageCacheService: imageCacheService
        )
        let galleryVC = GalleryViewController(viewModel: galleryVM)
        galleryVC.tabBarItem = UITabBarItem(title: "Gallery", image: UIImage(systemName: "photo.on.rectangle"), tag: 0)
        let galleryNav = UINavigationController(rootViewController: galleryVC)

        let favouritesVM = FavouritesViewModel(
            favouritesRepository: favouritesRepository,
            imageCacheService: imageCacheService
        )
        let favouritesVC = FavouritesViewController(viewModel: favouritesVM)
        favouritesVC.tabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "heart.fill"), tag: 1)
        let favouritesNav = UINavigationController(rootViewController: favouritesVC)

        tabBar.viewControllers = [galleryNav, favouritesNav]
        return tabBar
    }
}

