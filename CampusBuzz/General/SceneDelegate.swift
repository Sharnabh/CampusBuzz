//
//  SceneDelegate.swift
//  CampusBuzz
//
//  Created by Sharnabh on 21/06/25.
//

import UIKit
import CometChatUIKitSwift
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Initialize CometChat with config
        initializeCometChat { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.setupMainInterface(windowScene: windowScene)
                } else {
                    self?.showErrorInterface(windowScene: windowScene)
                }
            }
        }
    }
    
    private func initializeCometChat(completion: @escaping (Bool) -> Void) {
        // Verify configuration first
        guard CometChatConfig.isConfigured() else {
            print("❌ CometChat configuration is invalid")
            completion(false)
            return
        }
        
        print("🔧 Initializing CometChat with:")
        print("   App ID: \(CometChatConfig.appID)")
        print("   Region: \(CometChatConfig.region)")
        print("   Auth Key: \(String(CometChatConfig.authKey.prefix(10)))...")
        
        let uikitSettings = UIKitSettings()
            .set(appID: CometChatConfig.appID)
            .set(region: CometChatConfig.region)
            .set(authKey: CometChatConfig.authKey)
            .subscribePresenceForAllUsers()
            .build()
        
        CometChatUIKit.init(uiKitSettings: uikitSettings) { result in
            switch result {
            case .success:
                print("✅ CometChat UI Kit initialization succeeded")
                completion(true)
            case .failure(let error):
                print("❌ CometChat UI Kit initialization failed: \(error.localizedDescription)")
                print("   Error details: \(error)")
                completion(false)
            }
        }
    }
    
    private func setupMainInterface(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        
        // Check if user is already logged in to Firebase
        if FirebaseManager.shared.isUserSignedIn {
            // Firebase user exists, now check CometChat
            if CometChatUIKit.getLoggedInUser() != nil {
                // User is logged in to both, go to main app
                showMainApp()
            } else {
                // Firebase user exists but not logged into CometChat
                // Try to login/create CometChat user automatically
                autoLoginExistingFirebaseUser()
            }
        } else {
            // No Firebase user logged in, show authentication
            showAuthenticationFlow()
        }
        
        window?.makeKeyAndVisible()
    }
    
    func showMainApp() {
        // Load the main storyboard with tab bar controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateInitialViewController() {
            window?.rootViewController = tabBarController
        }
    }
    
    private func showAuthenticationFlow() {
        let authVC = AuthViewController()
        let navController = UINavigationController(rootViewController: authVC)
        window?.rootViewController = navController
    }
    
    private func showErrorInterface(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        let errorVC = UIViewController()
        errorVC.view.backgroundColor = .systemRed
        
        let label = UILabel()
        label.text = "CometChat initialization failed.\nCheck your network connection."
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        errorVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: errorVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: errorVC.view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: errorVC.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: errorVC.view.trailingAnchor, constant: -20)
        ])
        
        window?.rootViewController = errorVC
        window?.makeKeyAndVisible()
    }
    
    // TEMPORARY: Simple login for testing
    private func createTemporaryLoginVC() -> UIViewController {
        let loginVC = UIViewController()
        loginVC.view.backgroundColor = .systemBackground
        loginVC.title = "CampusBuzz Login"
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login as Test User", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        loginButton.addAction(UIAction { [weak self] _ in
            self?.loginTestUser()
        }, for: .touchUpInside)
        
        loginVC.view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: loginVC.view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: loginVC.view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return loginVC
    }
    
    private func loginTestUser() {
        let uid = "cometchat-uid-1" // TODO: Replace with proper user management
        
        CometChatManager.shared.loginUser(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ CometChat login succeeded for user: \(user.name ?? "Unknown")")
                    self?.showMainApp()
                case .failure(let error):
                    print("❌ CometChat login failed: \(error.localizedDescription)")
                    // Handle login error - maybe try to create user first
                    self?.createAndLoginTestUser()
                }
            }
        }
    }
    
    private func createAndLoginTestUser() {
        let uid = "cometchat-uid-1"
        let name = "Test Student"
        let email = "test.student@campus.edu"
        
        CometChatManager.shared.createUser(uid: uid, name: name, email: email, role: .student) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("✅ Test user created successfully")
                    // Now try to login
                    self?.loginTestUser()
                case .failure(let error):
                    print("❌ Test user creation failed: \(error.localizedDescription)")
                    // Show error or retry
                }
            }
        }
    }
    
    private func autoLoginExistingFirebaseUser() {
        guard let currentUser = FirebaseManager.shared.currentUser else {
            print("❌ No Firebase user found")
            showAuthenticationFlow()
            return
        }
        
        print("🔄 Firebase user exists, attempting CometChat login for: \(currentUser.uid)")
        
        // Try to login to CometChat with existing Firebase user
        CometChatManager.shared.loginUser(uid: currentUser.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Automatic CometChat login successful")
                    self?.showMainApp()
                case .failure(let error):
                    print("⚠️ CometChat login failed, creating user: \(error.localizedDescription)")
                    self?.createCometChatUserForExistingFirebaseUser(currentUser)
                }
            }
        }
    }
    
    private func createCometChatUserForExistingFirebaseUser(_ firebaseUser: FirebaseAuth.User) {
        let displayName = firebaseUser.displayName ?? firebaseUser.email?.components(separatedBy: "@").first ?? "User"
        
        CometChatManager.shared.createUser(
            uid: firebaseUser.uid,
            name: displayName,
            email: firebaseUser.email
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ CometChat user created, attempting login")
                    // Now try to login after creating the user
                    self?.loginToCometChatAutomatic(uid: firebaseUser.uid)
                case .failure(let error):
                    print("❌ Failed to create CometChat user: \(error.localizedDescription)")
                    // If creation fails, fall back to authentication flow
                    self?.showAuthenticationFlow()
                }
            }
        }
    }
    
    private func loginToCometChatAutomatic(uid: String) {
        CometChatManager.shared.loginUser(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Automatic CometChat login successful after user creation")
                    self?.showMainApp()
                case .failure(let error):
                    print("❌ CometChat login failed even after creation: \(error.localizedDescription)")
                    // If this fails, something is seriously wrong, show auth flow
                    self?.showAuthenticationFlow()
                }
            }
        }
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
    }

}





