import UIKit
import CometChatUIKitSwift
import CometChatSDK

class SelectUsersViewController: UIViewController {
    
    // MARK: - UI Components
    private var tableView: UITableView!
    private var searchController: UISearchController!
    private var activityIndicator: UIActivityIndicatorView!
    private var nextButton: UIBarButtonItem!
    
    // MARK: - Properties
    weak var delegate: SelectUsersDelegate?
    private var users: [User] = []
    private var filteredUsers: [User] = []
    private var selectedUsers: Set<String> = []
    private var isSearching: Bool = false
    private var usersRequest: UsersRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupTableView()
        setupActivityIndicator()
        fetchUsers()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "Select Users"
        view.backgroundColor = .systemBackground
        
        // Navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        nextButton = UIBarButtonItem(
            title: "Next",
            style: .done,
            target: self,
            action: #selector(nextTapped)
        )
        nextButton.isEnabled = false
        navigationItem.rightBarButtonItem = nextButton
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SelectUserTableViewCell.self, forCellReuseIdentifier: "SelectUserCell")
        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
    
    // MARK: - Data Methods
    
    private func fetchUsers() {
        activityIndicator.startAnimating()
        
        // Create users request
        usersRequest = UsersRequest.UsersRequestBuilder(limit: 50).build()
        
        usersRequest?.fetchNext() { [weak self] users in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                // Filter out current user
                if let currentUserUID = CometChat.getLoggedInUser()?.uid {
                    self?.users = users.filter { $0.uid != currentUserUID }
                } else {
                    self?.users = users
                }
                self?.filteredUsers = self?.users ?? []
                self?.tableView.reloadData()
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.showError(error?.errorDescription ?? "Failed to fetch users")
            }
        }
    }
    
    private func filterUsers(with searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
            isSearching = false
        } else {
            filteredUsers = users.filter { user in
                return user.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                       user.uid?.lowercased().contains(searchText.lowercased()) ?? false
            }
            isSearching = true
        }
        tableView.reloadData()
    }
    
    private func updateNextButtonState() {
        nextButton.isEnabled = !selectedUsers.isEmpty
        title = selectedUsers.isEmpty ? "Select Users" : "Select Users (\(selectedUsers.count))"
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Action Methods
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func nextTapped() {
        let selectedUserObjects = users.filter { selectedUsers.contains($0.uid ?? "") }
        delegate?.didSelectUsers(selectedUserObjects)
    }
}

// MARK: - UISearchResultsUpdating

extension SelectUsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterUsers(with: searchText)
    }
}

// MARK: - UITableViewDataSource

extension SelectUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUserCell", for: indexPath) as! SelectUserTableViewCell
        let user = filteredUsers[indexPath.row]
        let isSelected = selectedUsers.contains(user.uid ?? "")
        
        cell.configure(with: user, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SelectUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = filteredUsers[indexPath.row]
        guard let userUID = user.uid else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Toggle selection
        if selectedUsers.contains(userUID) {
            selectedUsers.remove(userUID)
        } else {
            selectedUsers.insert(userUID)
        }
        
        // Update UI
        tableView.reloadRows(at: [indexPath], with: .none)
        updateNextButtonState()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

// MARK: - Custom Cell

class SelectUserTableViewCell: UITableViewCell {
    
    private var userImageView: UIImageView!
    private var nameLabel: UILabel!
    private var statusLabel: UILabel!
    private var checkmarkView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // User image view
        userImageView = UIImageView()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 22
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = .systemGray5
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Name label
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Status label
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Checkmark view
        checkmarkView = UIImageView()
        checkmarkView.image = UIImage(systemName: "circle")
        checkmarkView.tintColor = .systemGray3
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(userImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(checkmarkView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 44),
            userImageView.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: checkmarkView.leadingAnchor, constant: -12),
            
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            statusLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            checkmarkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with user: User, isSelected: Bool) {
        nameLabel.text = user.name ?? user.uid
        statusLabel.text = user.status == .online ? "Online" : "Offline"
        
        // Update checkmark
        if isSelected {
            checkmarkView.image = UIImage(systemName: "checkmark.circle.fill")
            checkmarkView.tintColor = .systemBlue
        } else {
            checkmarkView.image = UIImage(systemName: "circle")
            checkmarkView.tintColor = .systemGray3
        }
        
        // Load avatar
        if let avatarUrl = user.avatar, let url = URL(string: avatarUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.userImageView.image = image
                    }
                }
            }.resume()
        } else {
            userImageView.image = UIImage(systemName: "person.circle.fill")
            userImageView.tintColor = .systemGray3
        }
    }
}

// MARK: - SelectUsersDelegate Protocol

protocol SelectUsersDelegate: AnyObject {
    func didSelectUsers(_ users: [User])
}
