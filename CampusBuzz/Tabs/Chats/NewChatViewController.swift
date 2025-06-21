import UIKit
import CometChatUIKitSwift
import CometChatSDK

class NewChatViewController: UIViewController {
    
    // MARK: - UI Components
    private var tableView: UITableView!
    private var searchController: UISearchController!
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    weak var delegate: NewChatDelegate?
    private var users: [User] = []
    private var filteredUsers: [User] = []
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
        title = "New Chat"
        view.backgroundColor = .systemBackground
        
        // Navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
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
                self?.users = users
                self?.filteredUsers = users
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
}

// MARK: - UISearchResultsUpdating

extension NewChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterUsers(with: searchText)
    }
}

// MARK: - UITableViewDataSource

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        
        cell.textLabel?.text = user.name ?? user.uid
        cell.detailTextLabel?.text = user.status == .online ? "Online" : "Offline"
        cell.accessoryType = .disclosureIndicator
        
        // Set avatar if available
        if let avatarUrl = user.avatar, let url = URL(string: avatarUrl) {
            // Load avatar image asynchronously
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if tableView.cellForRow(at: indexPath) == cell {
                            cell.imageView?.image = image
                            cell.setNeedsLayout()
                        }
                    }
                }
            }.resume()
        } else {
            cell.imageView?.image = UIImage(systemName: "person.circle")
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = filteredUsers[indexPath.row]
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Notify delegate about user selection
        delegate?.didSelectUser(user)
        
        // Navigate to messages with selected user
        let messagesVC = MessagesViewController.create(for: user)
        
        // Dismiss this modal and push messages
        dismiss(animated: true) {
            if let delegate = self.delegate as? UIViewController {
                delegate.navigationController?.pushViewController(messagesVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72 // Match the design requirements from Chats.md
    }
}

// MARK: - NewChatDelegate Protocol

protocol NewChatDelegate: AnyObject {
    func didSelectUser(_ user: User)
}
