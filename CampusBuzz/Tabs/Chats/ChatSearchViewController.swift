import UIKit
import CometChatUIKitSwift
import CometChatSDK

class ChatSearchViewController: UIViewController {
    
    // MARK: - UI Components
    private var searchController: UISearchController!
    private var segmentedControl: UISegmentedControl!
    private var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var currentSearchType: SearchType = .users
    private var users: [User] = []
    private var groups: [Group] = []
    private var filteredUsers: [User] = []
    private var filteredGroups: [Group] = []
    private var isSearching: Bool = false
    
    enum SearchType {
        case users
        case groups
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupSegmentedControl()
        setupTableView()
        setupActivityIndicator()
        fetchData()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "Search"
        view.backgroundColor = .systemBackground
        
        // Add close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users and groups"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Users", "Groups"])
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
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
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
    
    private func fetchData() {
        activityIndicator.startAnimating()
        fetchUsers()
        fetchGroups()
    }
    
    private func fetchUsers() {
        let usersRequest = UsersRequest.UsersRequestBuilder(limit: 50).build()
        
        usersRequest.fetchNext() { [weak self] users in
            DispatchQueue.main.async {
                self?.users = users
                self?.filteredUsers = users
                self?.checkLoadingComplete()
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.showError("Failed to load users: \(error?.errorDescription ?? "Unknown error")")
                self?.checkLoadingComplete()
            }
        }
    }
    
    private func fetchGroups() {
        let groupsRequest = GroupsRequest.GroupsRequestBuilder(limit: 50).build()
        
        groupsRequest.fetchNext() { [weak self] groups in
            DispatchQueue.main.async {
                self?.groups = groups
                self?.filteredGroups = groups
                self?.checkLoadingComplete()
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.showError("Failed to load groups: \(error?.errorDescription ?? "Unknown error")")
                self?.checkLoadingComplete()
            }
        }
    }
    
    private func checkLoadingComplete() {
        // Check if both users and groups have been loaded (or failed)
        if !users.isEmpty || !groups.isEmpty {
            activityIndicator.stopAnimating()
            updateSearchView()
            tableView.reloadData()
        }
    }
    
    private func updateSearchView() {
        searchController.searchBar.placeholder = currentSearchType == .users ? "Search users" : "Search groups"
        tableView.reloadData()
    }
    
    private func filterData(with searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
            filteredGroups = groups
            isSearching = false
        } else {
            filteredUsers = users.filter { user in
                return user.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                       user.uid?.lowercased().contains(searchText.lowercased()) ?? false
            }
            
            filteredGroups = groups.filter { group in
                return group.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                       group.guid.lowercased().contains(searchText.lowercased())
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
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentSearchType = sender.selectedSegmentIndex == 0 ? .users : .groups
        updateSearchView()
    }
}

// MARK: - UISearchResultsUpdating

extension ChatSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterData(with: searchText)
    }
}

// MARK: - UITableViewDataSource

extension ChatSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSearchType == .users ? filteredUsers.count : filteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if currentSearchType == .users {
            let user = filteredUsers[indexPath.row]
            cell.textLabel?.text = user.name ?? user.uid
            cell.detailTextLabel?.text = user.status == .online ? "Online" : "Offline"
            cell.imageView?.image = UIImage(systemName: "person.circle")
            
            // Load avatar if available
            if let avatarUrl = user.avatar, let url = URL(string: avatarUrl) {
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
            }
        } else {
            let group = filteredGroups[indexPath.row]
            cell.textLabel?.text = group.name ?? group.guid
            cell.detailTextLabel?.text = "\(group.membersCount) members"
            cell.imageView?.image = UIImage(systemName: "person.3.fill")
            
            // Load group icon if available
            if let iconUrl = group.icon, let url = URL(string: iconUrl) {
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
            }
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let messagesVC: MessagesViewController
        
        if currentSearchType == .users {
            let user = filteredUsers[indexPath.row]
            messagesVC = MessagesViewController.create(for: user)
        } else {
            let group = filteredGroups[indexPath.row]
            messagesVC = MessagesViewController.create(for: group)
        }
        
        navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72 // Match the design requirements from Chats.md
    }
}
