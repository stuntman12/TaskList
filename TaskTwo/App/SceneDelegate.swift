//
//  SceneDelegate.swift
//  TaskTwo
//
//  Created by Даниил on 25.11.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let taskVc = TaskTableViewController()
        window?.rootViewController = UINavigationController(rootViewController: taskVc)
        window?.makeKeyAndVisible()
    }
}

