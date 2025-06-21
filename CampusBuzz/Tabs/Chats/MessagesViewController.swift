import UIKit
import CometChatUIKitSwift
import CometChatSDK

class MessagesViewController: UIViewController {
    
    // MARK: - Properties
    private var messageList: CometChatMessageList!
    private var messageComposer: CometChatMessageComposer!
    private var user: User?
    private var group: Group?
    private var receiverType: CometChat.ReceiverType = .user
    
    // MARK: - Initialization
    
    init(user: User) {
        self.user = user
        self.receiverType = .user
        super.init(nibName: nil, bundle: nil)
    }
    
    init(group: Group) {
        self.group = group
        self.receiverType = .group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMessageList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure navigation bar
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureNavigationBar() {
        if let user = user {
            title = user.name ?? user.uid
        } else if let group = group {
            title = group.name
        }
        
        // Add back button functionality
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupMessageList() {
        // Create the message list view
        messageList = CometChatMessageList()
        messageList.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the message composer view
        messageComposer = CometChatMessageComposer()
        messageComposer.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure attachment options for the message composer
        messageComposer.set(attachmentOptions: { [weak self] user, group, controller in
            return MessageUtils.getDefaultAttachmentOptions(addtionalConfiguration: AdditionalConfiguration())
        })
        
        // Configure both components based on receiver type
        if let user = user {
            messageList.set(user: user)
            messageComposer.set(user: user)
        } else if let group = group {
            messageList.set(group: group)
            messageComposer.set(group: group)
        }
        
        // Add to view hierarchy
        view.addSubview(messageList)
        view.addSubview(messageComposer)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Message list constraints (takes most of the space)
            messageList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageList.bottomAnchor.constraint(equalTo: messageComposer.topAnchor),
            
            // Message composer constraints (bottom of screen)
            messageComposer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageComposer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageComposer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func set(conversationWith user: User, type: CometChat.ReceiverType) {
        self.user = user
        self.receiverType = type
        
        if isViewLoaded {
            messageList?.set(user: user)
            messageComposer?.set(user: user)
            title = user.name ?? user.uid
        }
    }
    
    func set(conversationWith group: Group, type: CometChat.ReceiverType) {
        self.group = group
        self.receiverType = type
        
        if isViewLoaded {
            messageList?.set(group: group)
            messageComposer?.set(group: group)
            title = group.name
        }
    }
}

// MARK: - Factory Methods

extension MessagesViewController {
    
    static func create(for user: User) -> MessagesViewController {
        let messagesVC = MessagesViewController(user: user)
        return messagesVC
    }
    
    static func create(for group: Group) -> MessagesViewController {
        let messagesVC = MessagesViewController(group: group)
        return messagesVC
    }
}
