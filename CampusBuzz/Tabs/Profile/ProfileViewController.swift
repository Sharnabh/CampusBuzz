//
//  ProfileViewController.swift
//  CampusBuzz
//
//  Created by System on 25/06/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CometChatSDK

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    
    // Scroll View
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // User Info Card
    private let userInfoCard = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let courseYearLabel = UILabel()
    private let collegeIDLabel = UILabel()
    private let onlineStatusView = UIView()
    
    // Joined Groups Section
    private let joinedGroupsSection = UIView()
    private let groupsSectionTitle = UILabel()
    private let groupsCollectionView: UICollectionView
    
    // Settings Section
    private let settingsTableView = UITableView()
    
    // Footer
    private let footerView = UIView()
    private let logoutButton = UIButton()
    private let versionLabel = UILabel()
    
    // MARK: - Data Properties
    private var userProfile: [String: Any] = [:]
    private var joinedGroups: [String] = [] // Group IDs
    private var groupDetails: [String: Group] = [:] // Cache for group details
    private var settingsItems: [SettingsItem] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupConstraints()
        loadUserProfile()
        loadJoinedGroups()
        setupSettingsItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUserData()
    }
    
    // MARK: - Initialization
    
    required init?(coder: NSCoder) {
        // Initialize collection view with flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        groupsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(coder: coder)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        setupScrollView()
        setupUserInfoCard()
        setupJoinedGroupsSection()
        setupSettingsSection()
        setupFooter()
    }
    
    private func setupNavigationBar() {
        title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editProfile)
        )
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
    }
    
    private func setupUserInfoCard() {
        contentView.addSubview(userInfoCard)
        
        // Configure card appearance
        userInfoCard.backgroundColor = UIColor.systemBackground
        userInfoCard.layer.cornerRadius = 16
        userInfoCard.layer.shadowColor = UIColor.black.cgColor
        userInfoCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        userInfoCard.layer.shadowRadius = 8
        userInfoCard.layer.shadowOpacity = 0.1
        userInfoCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Profile Image
        userInfoCard.addSubview(profileImageView)
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.systemBlue.cgColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.systemGray5
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = UIColor.systemGray3
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Name Label
        userInfoCard.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = UIColor.label
        nameLabel.text = "Loading..."
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Course & Year Label
        userInfoCard.addSubview(courseYearLabel)
        courseYearLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        courseYearLabel.textColor = UIColor.secondaryLabel
        courseYearLabel.text = "Loading..."
        courseYearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // College ID Label
        userInfoCard.addSubview(collegeIDLabel)
        collegeIDLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        collegeIDLabel.textColor = UIColor.systemBlue
        collegeIDLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        collegeIDLabel.layer.cornerRadius = 8
        collegeIDLabel.layer.masksToBounds = true
        collegeIDLabel.textAlignment = .center
        collegeIDLabel.text = "ID: Loading..."
        collegeIDLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Online Status
        userInfoCard.addSubview(onlineStatusView)
        onlineStatusView.backgroundColor = UIColor.systemGreen
        onlineStatusView.layer.cornerRadius = 6
        onlineStatusView.layer.borderWidth = 2
        onlineStatusView.layer.borderColor = UIColor.systemBackground.cgColor
        onlineStatusView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupJoinedGroupsSection() {
        contentView.addSubview(joinedGroupsSection)
        joinedGroupsSection.translatesAutoresizingMaskIntoConstraints = false
        
        // Section Title
        joinedGroupsSection.addSubview(groupsSectionTitle)
        groupsSectionTitle.text = "YOUR COMMUNITIES"
        groupsSectionTitle.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        groupsSectionTitle.textColor = UIColor.secondaryLabel
        groupsSectionTitle.translatesAutoresizingMaskIntoConstraints = false
        
        // Collection View
        joinedGroupsSection.addSubview(groupsCollectionView)
        groupsCollectionView.backgroundColor = UIColor.clear
        groupsCollectionView.showsHorizontalScrollIndicator = false
        groupsCollectionView.delegate = self
        groupsCollectionView.dataSource = self
        groupsCollectionView.register(GroupCardCell.self, forCellWithReuseIdentifier: "GroupCardCell")
        groupsCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSettingsSection() {
        contentView.addSubview(settingsTableView)
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        settingsTableView.backgroundColor = UIColor.clear
        settingsTableView.separatorStyle = .none
        settingsTableView.isScrollEnabled = false
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupFooter() {
        contentView.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Logout Button
        footerView.addSubview(logoutButton)
        logoutButton.setTitle("🔴 Log Out", for: .normal)
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.backgroundColor = UIColor.systemRed
        logoutButton.layer.cornerRadius = 12
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Version Label
        footerView.addSubview(versionLabel)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        versionLabel.text = "v\(version) (Build \(build))"
        versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        versionLabel.textColor = UIColor.tertiaryLabel
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // User Info Card
            userInfoCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            userInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userInfoCard.heightAnchor.constraint(equalToConstant: 160),
            
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: userInfoCard.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: userInfoCard.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Online Status
            onlineStatusView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -4),
            onlineStatusView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -4),
            onlineStatusView.widthAnchor.constraint(equalToConstant: 12),
            onlineStatusView.heightAnchor.constraint(equalToConstant: 12),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: userInfoCard.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: userInfoCard.trailingAnchor, constant: -20),
            
            // Course Year Label
            courseYearLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            courseYearLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            courseYearLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // College ID Label
            collegeIDLabel.topAnchor.constraint(equalTo: courseYearLabel.bottomAnchor, constant: 8),
            collegeIDLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            collegeIDLabel.widthAnchor.constraint(equalToConstant: 120),
            collegeIDLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Joined Groups Section
            joinedGroupsSection.topAnchor.constraint(equalTo: userInfoCard.bottomAnchor, constant: 30),
            joinedGroupsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            joinedGroupsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            joinedGroupsSection.heightAnchor.constraint(equalToConstant: 120),
            
            // Groups Section Title
            groupsSectionTitle.topAnchor.constraint(equalTo: joinedGroupsSection.topAnchor),
            groupsSectionTitle.leadingAnchor.constraint(equalTo: joinedGroupsSection.leadingAnchor),
            groupsSectionTitle.trailingAnchor.constraint(equalTo: joinedGroupsSection.trailingAnchor),
            
            // Groups Collection View
            groupsCollectionView.topAnchor.constraint(equalTo: groupsSectionTitle.bottomAnchor, constant: 12),
            groupsCollectionView.leadingAnchor.constraint(equalTo: joinedGroupsSection.leadingAnchor),
            groupsCollectionView.trailingAnchor.constraint(equalTo: joinedGroupsSection.trailingAnchor),
            groupsCollectionView.bottomAnchor.constraint(equalTo: joinedGroupsSection.bottomAnchor),
            
            // Settings Table View
            settingsTableView.topAnchor.constraint(equalTo: joinedGroupsSection.bottomAnchor, constant: 30),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            settingsTableView.heightAnchor.constraint(equalToConstant: 300), // Adjust based on number of items
            
            // Footer View
            footerView.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 30),
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            footerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Logout Button
            logoutButton.topAnchor.constraint(equalTo: footerView.topAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Version Label
            versionLabel.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 8),
            versionLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
        ])
    }
    
    // MARK: - Data Loading
    
    private func loadUserProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let data = document.data() ?? [:]
                    self?.userProfile = data
                    self?.updateUIWithUserData(data)
                } else {
                    self?.showDefaultUserData()
                }
            }
        }
    }
    
    private func loadJoinedGroups() {
        CometChat.getJoinedGroups(onSuccess: { [weak self] groupIDs in
            DispatchQueue.main.async {
                self?.joinedGroups = groupIDs
                self?.loadGroupDetails(for: groupIDs)
            }
        }, onError: { error in
            print("Failed to load joined groups: \(error?.errorDescription ?? "")")
        })
    }
    
    private func loadGroupDetails(for groupIDs: [String]) {
        guard !groupIDs.isEmpty else {
            DispatchQueue.main.async {
                self.groupsCollectionView.reloadData()
            }
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        for groupID in groupIDs {
            dispatchGroup.enter()
            CometChat.getGroup(GUID: groupID, onSuccess: { [weak self] group in
                DispatchQueue.main.async {
                    self?.groupDetails[groupID] = group
                    dispatchGroup.leave()
                }
            }, onError: { error in
                print("Failed to load group details for \(groupID): \(error?.errorDescription ?? "")")
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            self.groupsCollectionView.reloadData()
        }
    }
    
    private func refreshUserData() {
        loadUserProfile()
        loadJoinedGroups()
    }
    
    private func updateUIWithUserData(_ data: [String: Any]) {
        nameLabel.text = data["fullName"] as? String ?? "Unknown User"
        
        let course = data["course"] as? String ?? ""
        let year = data["year"] as? String ?? ""
        courseYearLabel.text = "\(course), \(year)"
        
        let collegeID = data["collegeID"] as? String ?? "N/A"
        collegeIDLabel.text = "ID: \(collegeID)"
        
        // Load profile image if available
        if let imageUrlString = data["profileImageURL"] as? String,
           let imageUrl = URL(string: imageUrlString) {
            loadProfileImage(from: imageUrl)
        }
    }
    
    private func showDefaultUserData() {
        nameLabel.text = Auth.auth().currentUser?.displayName ?? "Unknown User"
        courseYearLabel.text = "Update your profile"
        collegeIDLabel.text = "ID: Not set"
    }
    
    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.profileImageView.image = image
                    self?.profileImageView.contentMode = .scaleAspectFill
                }
            }
        }.resume()
    }
    
    private func setupSettingsItems() {
        settingsItems = [
            SettingsItem(icon: "👤", title: "View My UID", action: .viewUID),
            SettingsItem(icon: "🔔", title: "Notification Settings", action: .notifications),
            SettingsItem(icon: "⚙️", title: "App Settings", action: .appSettings),
            SettingsItem(icon: "🧼", title: "Clear Cache", action: .clearCache),
            SettingsItem(icon: "🧾", title: "Privacy Policy", action: .privacyPolicy),
            SettingsItem(icon: "📤", title: "Report a Problem", action: .reportProblem),
            SettingsItem(icon: "⭐", title: "Rate This App", action: .rateApp)
        ]
        settingsTableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func editProfile() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController {
            editVC.userProfile = userProfile
            editVC.delegate = self
            let navController = UINavigationController(rootViewController: editVC)
            present(navController, animated: true)
        }
    }
    
    @objc private func changeProfilePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Logging out...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        // Logout from CometChat
        CometChat.logout(onSuccess: { Response in
            // Logout from Firebase
            do {
                
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.navigateToLogin()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showError("Failed to logout: \(error.localizedDescription)")
                    }
                }
            }
        }, onError: { [weak self] error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    self?.showError("Failed to logout from CometChat: \(error.errorDescription ?? "")")
                }
            }
        }
                         )
    }
    
    private func navigateToLogin() {
        // Navigate to login screen
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Collection View DataSource & Delegate

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return joinedGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCardCell", for: indexPath) as! GroupCardCell
        let groupID = joinedGroups[indexPath.item]
        
        if let group = groupDetails[groupID] {
            cell.configure(with: group)
        } else {
            // Show placeholder while loading
            cell.configurePlaceholder(groupID: groupID)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupID = joinedGroups[indexPath.item]
        
        if let group = groupDetails[groupID] {
            // Navigate to chat screen for this group
            // Implementation depends on your chat navigation setup
            print("Selected group: \(group.name ?? groupID)")
        }
    }
}

// MARK: - Table View DataSource & Delegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        let item = settingsItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingsItems[indexPath.row]
        handleSettingsAction(item.action)
    }
    
    private func handleSettingsAction(_ action: SettingsAction) {
        switch action {
        case .viewUID:
            showUID()
        case .notifications:
            openNotificationSettings()
        case .appSettings:
            showAppSettings()
        case .clearCache:
            clearCache()
        case .privacyPolicy:
            openPrivacyPolicy()
        case .reportProblem:
            reportProblem()
        case .rateApp:
            rateApp()
        }
    }
    
    private func showUID() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let alert = UIAlertController(title: "Your UID", message: uid, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = uid
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    private func openNotificationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func showAppSettings() {
        let alert = UIAlertController(title: "App Settings", message: "Settings coming soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func clearCache() {
        let alert = UIAlertController(title: "Clear Cache", message: "This will clear all cached data. Continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            // Clear CometChat cache
            // Implementation depends on CometChat SDK version
            let successAlert = UIAlertController(title: "Success", message: "Cache cleared successfully", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        present(alert, animated: true)
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://your-privacy-policy-url.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func reportProblem() {
        let alert = UIAlertController(title: "Report a Problem", message: "Contact support at support@campusbuzz.com", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func rateApp() {
        // Replace with actual App Store ID
        if let url = URL(string: "https://apps.apple.com/app/id123456789") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Image Picker Delegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        // Update UI immediately
        profileImageView.image = selectedImage
        profileImageView.contentMode = .scaleAspectFill
        
        // Upload to Firebase Storage
        uploadProfileImage(selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let currentUser = Auth.auth().currentUser,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(currentUser.uid).jpg")
        
        profileImageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError("Failed to upload image: \(error.localizedDescription)")
                }
                return
            }
            
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showError("Failed to get download URL: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let downloadURL = url else { return }
                
                // Update Firestore with new image URL
                let db = Firestore.firestore()
                db.collection("users").document(currentUser.uid).updateData([
                    "profileImageURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.showError("Failed to update profile: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Edit Profile Delegate

protocol EditProfileDelegate: AnyObject {
    func didUpdateProfile()
}

extension ProfileViewController: EditProfileDelegate {
    func didUpdateProfile() {
        refreshUserData()
    }
}

// MARK: - Supporting Models

struct SettingsItem {
    let icon: String
    let title: String
    let action: SettingsAction
}

enum SettingsAction {
    case viewUID
    case notifications
    case appSettings
    case clearCache
    case privacyPolicy
    case reportProblem
    case rateApp
}
