import UIKit
import CometChatUIKitSwift
import CometChatSDK

class ChatsViewController: UIViewController {
    
    // MARK: - UI Components
    private var conversationList: CometChatConversations!
    private var segmentedControl: UISegmentedControl!
    private var emptyStateView: UIView!
    private var emptyStateLabel: UILabel!
    private var joinGroupButton: UIButton!
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var currentConversationType: CometChat.ConversationType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentedControl()
        setupConversationList()
        setupEmptyState()
        setupActivityIndicator()
        checkCometChatStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshConversations()
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigationBar() {
        self.title = "Chats"
        
        // Configure navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Right bar button items
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchTapped)
        )
        
        let newChatButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(newChatTapped)
        )
        
        navigationItem.rightBarButtonItems = [newChatButton, searchButton]
        
        // Left bar button item - profile avatar placeholder
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        navigationItem.leftBarButtonItem = profileButton
    }
    
    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["All", "Groups", "Direct Messages"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupConversationList() {
        setupConversationListWithFilter(conversationType: .none)
    }
    
    private func setupConversationListWithFilter(conversationType: CometChat.ConversationType) {
        print("🔧 Setting up conversation list with filter: \(conversationType)")
        
        // Remove existing conversation list if it exists
        if conversationList != nil {
            conversationList.willMove(toParent: nil)
            conversationList.view.removeFromSuperview()
            conversationList.removeFromParent()
        }
        
        // Create new conversation list with the specified filter
        conversationList = CometChatConversations()
        
        // Set up conversation request builder with the specified filter
        let requestBuilder = ConversationRequest.ConversationRequestBuilder(limit: 30)
        
        // Apply the conversation type filter
        switch conversationType {
        case .user:
            print("📱 Filtering for user conversations only")
            requestBuilder.setConversationType(conversationType: .user)
        case .group:
            print("👥 Filtering for group conversations only")
            requestBuilder.setConversationType(conversationType: .group)
        case .none:
            print("📋 Showing all conversations (no filter)")
            // Don't set any filter for "All" - this will show both users and groups
            break
        @unknown default:
            break
        }
        
        conversationList.set(conversationRequestBuilder: requestBuilder)
        
        // Set up tap handler using closure-based API
        conversationList.set(onItemClick: { [weak self] conversation, indexPath in
            self?.handleConversationTap(conversation: conversation, indexPath: indexPath)
        })
        
        // Add as child view controller
        addChild(conversationList)
        conversationList.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(conversationList.view)
        conversationList.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            conversationList.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            conversationList.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            conversationList.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            conversationList.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshConversations), for: .valueChanged)
        if let tableView = conversationList.view.subviews.first(where: { $0 is UITableView }) as? UITableView {
            tableView.refreshControl = refreshControl
        }
    }
    
    private func setupEmptyState() {
        emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No conversations yet."
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        joinGroupButton = UIButton(type: .system)
        joinGroupButton.setTitle("Join a Group", for: .normal)
        joinGroupButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        joinGroupButton.backgroundColor = .systemBlue
        joinGroupButton.setTitleColor(.white, for: .normal)
        joinGroupButton.layer.cornerRadius = 8
        joinGroupButton.addTarget(self, action: #selector(joinGroupTapped), for: .touchUpInside)
        joinGroupButton.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(joinGroupButton)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            joinGroupButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 24),
            joinGroupButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            joinGroupButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            joinGroupButton.widthAnchor.constraint(equalToConstant: 150),
            joinGroupButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func checkCometChatStatus() {
        if CometChat.getLoggedInUser() != nil {
            print("✅ CometChat user is logged in")
            refreshConversations()
        } else {
            print("❌ No CometChat user logged in")
            showEmptyState(true)
        }
    }
    
    private func showEmptyState(_ show: Bool) {
        DispatchQueue.main.async {
            self.emptyStateView.isHidden = !show
            self.conversationList.view.isHidden = show
        }
    }
    
    private func showLoading(_ show: Bool) {
        DispatchQueue.main.async {
            if show {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func searchTapped() {
        let searchVC = ChatSearchViewController()
        let navController = UINavigationController(rootViewController: searchVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func newChatTapped() {
        let actionSheet = UIAlertController(title: "New Chat", message: "Choose an option", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Start Direct Message", style: .default) { _ in
            self.startDirectMessage()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Create Group", style: .default) { _ in
            self.createGroup()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure for iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }
        
        present(actionSheet, animated: true)
    }
    
    @objc private func profileTapped() {
        // TODO: Navigate to profile or show profile options
        print("Profile tapped")
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let previousType = currentConversationType
        
        switch sender.selectedSegmentIndex {
        case 0: // All
            currentConversationType = .none
        case 1: // Groups
            currentConversationType = .group
        case 2: // Direct Messages
            currentConversationType = .user
        default:
            currentConversationType = .none
        }
        
        print("🔄 Segment changed from \(previousType) to \(currentConversationType)")
        
        // Remove the current conversation list and recreate it with the new filter
        setupConversationListWithFilter(conversationType: currentConversationType)
    }
    
    @objc private func refreshConversations() {
        conversationList.reload()
        
        // Stop refresh control if it's active
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let tableView = self.conversationList.view.subviews.first(where: { $0 is UITableView }) as? UITableView {
                tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func joinGroupTapped() {
        // Navigate to Explore tab to join groups
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1 // Assuming Explore is at index 1
        }
    }
    
    // MARK: - Private Methods
    
    private func startDirectMessage() {
        let newChatVC = NewChatViewController()
        newChatVC.delegate = self
        let navController = UINavigationController(rootViewController: newChatVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    private func createGroup() {
        let selectUsersVC = SelectUsersViewController()
        selectUsersVC.delegate = self
        let navController = UINavigationController(rootViewController: selectUsersVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    // MARK: - Conversation Handling
    
    private func handleConversationTap(conversation: CometChatSDK.Conversation, indexPath: IndexPath) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Navigate to messages screen
        let messagesVC: MessagesViewController
        
        if let user = conversation.conversationWith as? User {
            messagesVC = MessagesViewController.create(for: user)
        } else if let group = conversation.conversationWith as? Group {
            messagesVC = MessagesViewController.create(for: group)
        } else {
            return // Unable to determine conversation type
        }
        
        navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    func onItemLongClick(conversation: CometChatSDK.Conversation, index: IndexPath?) {
        // Show quick actions (pin conversation, etc.)
        let actionSheet = UIAlertController(title: "Conversation Options", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Pin Conversation", style: .default) { _ in
            // TODO: Implement pin functionality
            print("Pin conversation")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Mark as Unread", style: .default) { _ in
            // TODO: Implement mark as unread
            print("Mark as unread")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Mute", style: .default) { _ in
            // TODO: Implement mute functionality
            print("Mute conversation")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure for iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(actionSheet, animated: true)
    }
    
    func onError(conversation: CometChatSDK.Conversation?, error: CometChatSDK.CometChatException) {
        DispatchQueue.main.async {
            print("❌ Conversation list error: \(error.errorDescription)")
            
            // Show error message to user
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to load conversations. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                self.refreshConversations()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
}

// MARK: - NewChatDelegate

extension ChatsViewController: NewChatDelegate {
    func didSelectUser(_ user: User) {
        print("✅ Selected user for chat: \(user.name ?? "Unknown")")
        // The NewChatViewController handles navigation to messages
        // This delegate method is called for additional handling if needed
    }
}

// MARK: - CreateGroupDelegate

extension ChatsViewController: CreateGroupDelegate {
    func didCreateGroup(_ group: Group) {
        print("✅ Created group: \(group.name ?? "Unknown")")
        
        // Navigate to the newly created group's messages
        let messagesVC = MessagesViewController.create(for: group)
        navigationController?.pushViewController(messagesVC, animated: true)
        
        // Refresh conversations to show the new group with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshConversations()
        }
    }
}

// MARK: - SelectUsersDelegate

extension ChatsViewController: SelectUsersDelegate {
    func didSelectUsers(_ users: [User]) {
        // Dismiss the user selection view and show group creation
        dismiss(animated: true) {
            let createGroupVC = CreateGroupViewController()
            createGroupVC.delegate = self
            createGroupVC.setSelectedUsers(users)
            
            let navController = UINavigationController(rootViewController: createGroupVC)
            navController.modalPresentationStyle = .pageSheet
            self.present(navController, animated: true)
        }
    }
}
