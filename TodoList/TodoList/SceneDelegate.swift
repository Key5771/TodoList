//
//  SceneDelegate.swift
//  TodoList
//
//  Created by 김기현 on 2020/10/16.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // ViewController를 Code 기반으로 생성
        let mainViewController = ViewController()
        
        // NavigationController 생성 및 설정
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        // NavigationController 기본 설정
        setupNavigationController(navigationController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func setupNavigationController(_ navigationController: UINavigationController) {
        // 자연스러운 네비게이션 애니메이션을 위한 설정
        navigationController.delegate = self
        
        // NavigationBar 기본 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        // Large Title 폰트 설정
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        // 일반 Title 폰트 설정
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        // Back 버튼 설정
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left"), transitionMaskImage: UIImage(systemName: "chevron.left"))
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        
        // Large Title 기본 활성화
        navigationController.navigationBar.prefersLargeTitles = true
        
        // 제스처 기반 네비게이션 활성화
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        // Tint 색상 설정
        navigationController.navigationBar.tintColor = .systemBlue
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

// MARK: - UINavigationControllerDelegate
extension SceneDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 네비게이션 애니메이션 커스터마이징
        
        // Large Title 동적 설정
        if viewController is ViewController {
            // 메인 화면: Large Title 활성화
            navigationController.navigationBar.prefersLargeTitles = true
            viewController.navigationItem.largeTitleDisplayMode = .always
        } else {
            // 상세 화면들: Large Title 비활성화
            navigationController.navigationBar.prefersLargeTitles = true
            viewController.navigationItem.largeTitleDisplayMode = .never
        }
        
        // 부드러운 전환을 위한 설정
        navigationController.view.backgroundColor = .systemBackground
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 네비게이션 완료 후 처리
        
        // Interactive Pop Gesture 설정
        if navigationController.viewControllers.count > 1 {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = nil
        } else {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 커스텀 애니메이션이 필요한 경우 여기서 구현
        // 기본 애니메이션을 사용하므로 nil 반환
        return nil
    }
}
