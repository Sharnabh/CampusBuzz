import UIKit
import CometChatUIKitSwift
import CometChatSDK

class ExploreViewController: UIViewController {
    
    // MARK: - UI Components
    private var searchController: UISearchController!
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var contentStackView: UIStackView!
    
    // Featured Section
    private var featuredCollectionView: UICollectionView!
    
    // Category Filters
    private var categoryCollectionView: UICollectionView!
    
    // Groups List
    private var groupsTableView: UITableView!
    
    // Suggested Section
    private var suggestedCollectionView: UICollectionView!
    
    // Floating Action Button
    private var createGroupFAB: UIButton!
    
    // Activity Indicator
    private var activityIndicator: UIActivityIndicatorView!
    
    // Empty State
    private var emptyStateView: UIView!
    private var emptyStateLabel: UILabel!
    
    // MARK: - Properties
    private var allGroups: [Group] = []
    private var filteredGroups: [Group] = []
    private var featuredGroups: [Group] = []
    private var suggestedGroups: [Group] = []
    private var categories: [ExploreCategory] = []
    private var selectedCategory: ExploreCategory = .all
    private var isSearching: Bool = false
    
    // Constraint references
    private var groupsTableHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupScrollView()
        setupFeaturedSection()
        setupCategoryFilters()
        setupGroupsList()
        setupSuggestedSection()
        setupFloatingActionButton()
        setupEmptyState()
        setupActivityIndicator()
        setupDemoData() // Create sample groups if needed
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "Explore"
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        // Filter button on the right
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        navigationItem.rightBarButtonItem = filterButton
        
        // Configure navigation appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search groups or users"
        searchController.searchBar.searchBarStyle = .minimal
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupFeaturedSection() {
        let sectionLabel = createSectionLabel(text: "Featured Groups")
        contentStackView.addArrangedSubview(sectionLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 280, height: 140)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        featuredCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        featuredCollectionView.backgroundColor = .clear
        featuredCollectionView.showsHorizontalScrollIndicator = false
        featuredCollectionView.delegate = self
        featuredCollectionView.dataSource = self
        featuredCollectionView.register(FeaturedGroupCell.self, forCellWithReuseIdentifier: "FeaturedGroupCell")
        featuredCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(featuredCollectionView)
        featuredCollectionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    private func setupCategoryFilters() {
        let sectionLabel = createSectionLabel(text: "Categories")
        contentStackView.addArrangedSubview(sectionLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryFilterCell.self, forCellWithReuseIdentifier: "CategoryFilterCell")
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(categoryCollectionView)
        categoryCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Setup categories
        categories = ExploreCategory.allCases
    }
    
    private func setupGroupsList() {
        let headerStack = createSectionHeaderWithViewAll(
            title: "Discover Groups",
            action: #selector(viewAllGroups)
        )
        contentStackView.addArrangedSubview(headerStack)
        
        groupsTableView = UITableView()
        groupsTableView.backgroundColor = .clear
        groupsTableView.separatorStyle = .none
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        groupsTableView.register(ExploreGroupCell.self, forCellReuseIdentifier: "ExploreGroupCell")
        groupsTableView.translatesAutoresizingMaskIntoConstraints = false
        groupsTableView.isScrollEnabled = false // Let the main scroll view handle scrolling
        
        contentStackView.addArrangedSubview(groupsTableView)
        groupsTableHeightConstraint = groupsTableView.heightAnchor.constraint(equalToConstant: 400)
        groupsTableHeightConstraint?.isActive = true
    }
    
    private func setupSuggestedSection() {
        let sectionLabel = createSectionLabel(text: "Suggested for You")
        contentStackView.addArrangedSubview(sectionLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 120)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        suggestedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        suggestedCollectionView.backgroundColor = .clear
        suggestedCollectionView.showsHorizontalScrollIndicator = false
        suggestedCollectionView.delegate = self
        suggestedCollectionView.dataSource = self
        suggestedCollectionView.register(SuggestedGroupCell.self, forCellWithReuseIdentifier: "SuggestedGroupCell")
        suggestedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(suggestedCollectionView)
        suggestedCollectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    private func setupFloatingActionButton() {
        createGroupFAB = UIButton(type: .system)
        createGroupFAB.setImage(UIImage(systemName: "plus"), for: .normal)
        createGroupFAB.tintColor = .white
        createGroupFAB.backgroundColor = .systemBlue
        createGroupFAB.layer.cornerRadius = 28
        createGroupFAB.layer.shadowColor = UIColor.black.cgColor
        createGroupFAB.layer.shadowOffset = CGSize(width: 0, height: 2)
        createGroupFAB.layer.shadowRadius = 8
        createGroupFAB.layer.shadowOpacity = 0.3
        createGroupFAB.addTarget(self, action: #selector(createGroupTapped), for: .touchUpInside)
        createGroupFAB.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(createGroupFAB)
        
        NSLayoutConstraint.activate([
            createGroupFAB.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createGroupFAB.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createGroupFAB.widthAnchor.constraint(equalToConstant: 56),
            createGroupFAB.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateView = UIView()
        emptyStateView.backgroundColor = .clear
        emptyStateView.isHidden = true
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No groups found. Try a different category or search term."
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .systemFont(ofSize: 16)
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func createSectionLabel(text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.addSubview(label)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createSectionHeaderWithViewAll(title: String, action: Selector) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .label
        
        let viewAllButton = UIButton(type: .system)
        viewAllButton.setTitle("View All", for: .normal)
        viewAllButton.titleLabel?.font = .systemFont(ofSize: 16)
        viewAllButton.setTitleColor(.systemBlue, for: .normal)
        viewAllButton.addTarget(self, action: action, for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, viewAllButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        return stackView
    }
    
    // MARK: - Data Methods
    
    private func loadData() {
        activityIndicator.startAnimating()
        fetchGroups()
    }
    
    private func refreshData() {
        fetchGroups()
    }
    
    private func fetchGroups() {
        print("🔍 ExploreViewController: Starting to fetch groups...")
        
        // Check if CometChat user is logged in
        guard CometChatManager.shared.isUserLoggedIn() else {
            print("❌ ExploreViewController: User not logged in to CometChat")
            activityIndicator.stopAnimating()
            loadMockData()
            return
        }
        
        print("✅ ExploreViewController: User is logged in, fetching groups...")
        
        CometChatManager.shared.fetchGroups { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let groups):
                    print("✅ ExploreViewController: Successfully fetched \(groups.count) groups")
                    
                    // Log details about each group for debugging
                    for (index, group) in groups.enumerated() {
                        print("   Group \(index + 1): '\(group.name ?? "No Name")' - \(group.guid) - Members: \(group.membersCount)")
                        if let metadata = group.metadata {
                            print("     Metadata: \(metadata)")
                        }
                    }
                    
                    if groups.isEmpty {
                        print("⚠️ ExploreViewController: No groups found, keeping current mock data...")
                        // Don't replace mock data if we have it
                        if self?.allGroups.isEmpty == true {
                            self?.loadMockData()
                        } else {
                            print("📝 Keeping existing data since fetch returned empty")
                        }
                    } else {
                        self?.allGroups = groups
                        self?.filteredGroups = groups
                        self?.setupFeaturedGroups()
                        self?.setupSuggestedGroups()
                        self?.updateUI()
                    }
                case .failure(let error):
                    print("❌ ExploreViewController: Failed to fetch groups: \(error)")
                    print("🔄 ExploreViewController: Keeping existing data or loading mock data...")
                    if self?.allGroups.isEmpty == true {
                        self?.loadMockData()
                    }
                }
            }
        }
    }
    
    private func loadMockData() {
        print("📝 ExploreViewController: Loading mock data...")
        
        // Stop activity indicator
        activityIndicator.stopAnimating()
        
        // Create mock groups for demonstration
        let mockGroups = createMockGroups()
        
        allGroups = mockGroups
        filteredGroups = mockGroups
        setupFeaturedGroups()
        setupSuggestedGroups()
        updateUI()
        
        print("✅ ExploreViewController: Mock data loaded with \(mockGroups.count) groups")
    }
    
    private func createMockGroups() -> [Group] {
        var mockGroups: [Group] = []
        
        // Create different types of mock groups with icons and better metadata
        let groupData = [
            ("🎓 BTech CSE Sem 5", "Academic discussion for Computer Science Engineering", "academic", "semester"),
            ("📸 Photography Club", "Share your best shots and learn photography tips", "club", "club"),
            ("🎮 Gaming Squad", "Discuss latest games and organize tournaments", "gaming", "club"),
            ("💪 Fitness Enthusiasts", "Share workout tips and motivate each other", "sports", "club"),
            ("💼 Career Guidance", "Get advice on internships and job opportunities", "career", "general"),
            ("🏠 Hostel Block A", "Connect with your hostel mates", "dorm", "general"),
            ("📐 Study Group - Math", "Solve math problems together", "academic", "study"),
            ("🎭 Drama Society", "Theater and performing arts community", "club", "club"),
            ("🏀 Basketball Team", "Join our basketball training sessions", "sports", "club"),
            ("🚀 Tech Startups", "Discuss entrepreneurship and startup ideas", "career", "general")
        ]
        
        for (index, (name, description, category, type)) in groupData.enumerated() {
            let group = Group(
                guid: "mock_group_\(index)",
                name: name,
                groupType: index % 3 == 0 ? .private : .public,
                password: nil
            )
            group.groupDescription = description
            group.membersCount = Int.random(in: 5...150)
            
            // Add comprehensive metadata for categorization
            group.metadata = [
                "category": category,
                "type": type,
                "college": "Mock University",
                "created_by": "CampusBuzz_Mock",
                "icon": String(name.prefix(2)) // Extract emoji
            ]
            
            mockGroups.append(group)
        }
        
        return mockGroups
    }
    
    private func setupFeaturedGroups() {
        // Select first 5 groups as featured for demo
        featuredGroups = Array(allGroups.prefix(5))
    }
    
    private func setupSuggestedGroups() {
        // Select some groups as suggested for demo
        suggestedGroups = Array(allGroups.dropFirst(5).prefix(3))
    }
    
    private func filterGroups() {
        var filtered = allGroups
        
        // Filter by category
        if selectedCategory != .all {
            filtered = filtered.filter { group in
                // Check metadata first
                if let metadata = group.metadata,
                   let category = metadata["category"] as? String {
                    return category.lowercased().contains(selectedCategory.searchKeyword.lowercased())
                }
                
                // Fallback to group name matching
                return group.name?.lowercased().contains(selectedCategory.searchKeyword.lowercased()) ?? false
            }
        }
        
        // Filter by search text
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filtered = filtered.filter { group in
                return group.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                       group.groupDescription?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        
        filteredGroups = filtered
        updateUI()
        
        print("🔍 ExploreViewController: Filtered groups - Category: \(selectedCategory.displayName), Count: \(filtered.count)")
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            print("🔄 ExploreViewController: Updating UI...")
            print("   - All groups: \(self.allGroups.count)")
            print("   - Filtered groups: \(self.filteredGroups.count)")
            print("   - Featured groups: \(self.featuredGroups.count)")
            print("   - Suggested groups: \(self.suggestedGroups.count)")
            
            self.groupsTableView.reloadData()
            self.featuredCollectionView.reloadData()
            self.suggestedCollectionView.reloadData()
            self.categoryCollectionView.reloadData()
            
            // Update table view height based on content
            let cellHeight: CGFloat = 80
            let tableHeight = CGFloat(min(self.filteredGroups.count, 5)) * cellHeight
            self.groupsTableHeightConstraint?.constant = max(tableHeight, 80) // Minimum height
            
            // Show/hide empty state
            let hasContent = !self.filteredGroups.isEmpty || !self.featuredGroups.isEmpty
            self.emptyStateView.isHidden = hasContent
            self.scrollView.isHidden = !hasContent
            
            print("   - Table height: \(self.groupsTableHeightConstraint?.constant ?? 0)")
            print("   - Has content: \(hasContent)")
            print("✅ ExploreViewController: UI update completed")
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Action Methods
    
    @objc private func filterTapped() {
        // Show filter options
        let alert = UIAlertController(title: "Filter Groups", message: "Choose filter options", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Public Groups", style: .default) { _ in
            // Filter logic
        })
        
        alert.addAction(UIAlertAction(title: "Private Groups", style: .default) { _ in
            // Filter logic
        })
        
        alert.addAction(UIAlertAction(title: "Reset Filters", style: .default) { _ in
            self.selectedCategory = .all
            self.filterGroups()
        })
        
        // Add option to create sample groups for testing
        alert.addAction(UIAlertAction(title: "Create Sample Groups", style: .default) { _ in
            print("🔧 Manual group creation triggered...")
            self.createRealSampleGroups()
        })
        
        alert.addAction(UIAlertAction(title: "Refresh Groups", style: .default) { _ in
            print("🔄 Manual refresh triggered...")
            self.fetchGroups()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure for iPad
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    @objc private func createGroupTapped() {
        let createGroupVC = CreateGroupViewController()
        createGroupVC.delegate = self
        let navController = UINavigationController(rootViewController: createGroupVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func viewAllGroups() {
        // Navigate to full groups list
        print("View all groups tapped")
    }
    
    private func joinGroup(_ group: Group) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        CometChatManager.shared.joinGroup(guid: group.guid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.showSuccessMessage("Joined \(group.name ?? "group") successfully!")
                    self?.refreshData()
                case .failure(let error):
                    self?.showErrorAlert("Failed to join group: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension ExploreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
        filterGroups()
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count: Int
        switch collectionView {
        case featuredCollectionView:
            count = featuredGroups.count
            print("📱 FeaturedCollectionView items: \(count)")
        case categoryCollectionView:
            count = categories.count
            print("📱 CategoryCollectionView items: \(count)")
        case suggestedCollectionView:
            count = suggestedGroups.count
            print("📱 SuggestedCollectionView items: \(count)")
        default:
            count = 0
            print("📱 Unknown CollectionView")
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case featuredCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedGroupCell", for: indexPath) as! FeaturedGroupCell
            cell.configure(with: featuredGroups[indexPath.item])
            cell.onJoinTapped = { [weak self] group in
                self?.joinGroup(group)
            }
            return cell
            
        case categoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryFilterCell", for: indexPath) as! CategoryFilterCell
            let category = categories[indexPath.item]
            cell.configure(with: category, isSelected: category == selectedCategory)
            return cell
            
        case suggestedCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedGroupCell", for: indexPath) as! SuggestedGroupCell
            cell.configure(with: suggestedGroups[indexPath.item])
            cell.onJoinTapped = { [weak self] group in
                self?.joinGroup(group)
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategory = categories[indexPath.item]
            filterGroups()
        } else if collectionView == featuredCollectionView {
            let group = featuredGroups[indexPath.item]
            showGroupDetails(group)
        } else if collectionView == suggestedCollectionView {
            let group = suggestedGroups[indexPath.item]
            showGroupDetails(group)
        }
    }
    
    private func showGroupDetails(_ group: Group) {
        // For now, just join the group
        // In production, you'd show a group details modal
        joinGroup(group)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = min(filteredGroups.count, 5) // Limit to 5 items in embedded table
        print("🗂️ GroupsTableView rows: \(count) (filtered: \(filteredGroups.count))")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreGroupCell", for: indexPath) as! ExploreGroupCell
        let group = filteredGroups[indexPath.row]
        cell.configure(with: group)
        cell.onJoinTapped = { [weak self] group in
            self?.joinGroup(group)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let group = filteredGroups[indexPath.row]
        showGroupDetails(group)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - CreateGroupDelegate

extension ExploreViewController: CreateGroupDelegate {
    func didCreateGroup(_ group: Group) {
        print("✅ Created group: \(group.name ?? "Unknown")")
        
        // Navigate to the newly created group's messages
        let messagesVC = MessagesViewController.create(for: group)
        navigationController?.pushViewController(messagesVC, animated: true)
        
        // Refresh data to show the new group
        refreshData()
    }
}

// MARK: - Sample Data Creation

extension ExploreViewController {
    
    /// Create sample groups for demo purposes
    func createSampleGroups() {
        print("🔧 Creating sample groups for demo...")
        
        let sampleGroups = [
            // Featured groups
            ("Computer Science Students", CometChatConfig.GroupType.semester, "Welcome to all CS students! Share notes, discuss assignments, and connect with peers."),
            ("Drama Club", CometChatConfig.GroupType.club, "Join our drama performances, workshops, and creative discussions!"),
            ("Data Structures Study Group", CometChatConfig.GroupType.study, "Let's master algorithms and data structures together."),
            
            // Regular groups
            ("Basketball Team", CometChatConfig.GroupType.club, "Official campus basketball team. Training schedules and match updates."),
            ("Web Development", CometChatConfig.GroupType.course, "Learn modern web technologies - HTML, CSS, JavaScript, React."),
            ("Photography Club", CometChatConfig.GroupType.club, "Capture moments, share techniques, organize photo walks."),
            ("Machine Learning Study", CometChatConfig.GroupType.study, "Explore AI/ML concepts, share resources, work on projects."),
            ("Campus Events", CometChatConfig.GroupType.general, "Stay updated with all campus events, workshops, and announcements.")
        ]
        
        let college = "Sample University"
        var successCount = 0
        
        // First, try to create a simple test group to see if creation works
        print("🧪 Testing group creation with a simple test group...")
        
        // Create a unique test group first
        let testGroupName = "Test Group \(Date().timeIntervalSince1970)"
        CometChatManager.shared.createCampusGroup(
            name: testGroupName,
            type: .general,
            college: college,
            description: "This is a test group to verify creation works."
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let group):
                    print("✅ Test group creation successful: \(group.name ?? "Unknown") with ID: \(group.guid)")
                    
                    // Now create the actual sample groups
                    self?.createActualSampleGroups(sampleGroups, college: college)
                    
                case .failure(let error):
                    print("❌ Test group creation failed: \(error.localizedDescription)")
                    print("🔄 Falling back to mock data since group creation doesn't work...")
                    self?.loadMockData()
                }
            }
        }
    }
    
    private func createActualSampleGroups(_ sampleGroups: [(String, CometChatConfig.GroupType, String)], college: String) {
        print("🏗️ Creating actual sample groups...")
        
        var successCount = 0
        let totalGroups = sampleGroups.count
        
        for (index, groupData) in sampleGroups.enumerated() {
            let (name, type, description) = groupData
            
            // Add timestamp to make group names unique
            let uniqueName = "\(name) \(Int(Date().timeIntervalSince1970) + index)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
                print("🏗️ Creating group \(index + 1)/\(totalGroups): \(uniqueName)")
                
                CometChatManager.shared.createCampusGroup(
                    name: uniqueName,
                    type: type,
                    college: college,
                    description: description
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let group):
                            successCount += 1
                            print("✅ Created sample group \(successCount)/\(totalGroups): \(group.name ?? "Unknown") with ID: \(group.guid)")
                            
                            // Update UI after creating a few groups or when done
                            if successCount == 3 || successCount == totalGroups {
                                print("🔄 Refreshing data after \(successCount) groups created...")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.fetchGroups()
                                }
                            }
                            
                        case .failure(let error):
                            print("❌ Failed to create sample group '\(uniqueName)': \(error.localizedDescription)")
                            
                            // If too many failures, fall back to mock data
                            if index == 0 && successCount == 0 {
                                print("🔄 First group creation failed, falling back to mock data...")
                                self.loadMockData()
                            }
                        }
                    }
                }
            }
        }
        
        // Final refresh after all groups should be created
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalGroups) * 1.5 + 3.0) {
            print("🔄 Final refresh after all group creation attempts...")
            self.fetchGroups()
        }
    }
    
    /// Add this to viewDidLoad for demo purposes
    private func setupDemoData() {
        print("🎯 ExploreViewController: Setting up demo data...")
        
        // Load mock data immediately for instant feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("📝 Loading immediate mock data...")
            self.loadMockData()
        }
        
        // Try to create real groups in CometChat using the batch method
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("🏗️ Creating real sample groups in CometChat...")
            self.createRealSampleGroups()
        }
    }
    
    private func createRealSampleGroups() {
        print("🔧 Creating real sample groups using batch method...")
        
        CometChatManager.shared.createSampleGroupsBatch { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    print("✅ Successfully created \(groups.count) real groups!")
                    
                    // Refresh the UI to show real groups
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        print("🔄 Refreshing UI with real groups...")
                        self?.fetchGroups()
                    }
                    
                case .failure(let error):
                    print("❌ Batch group creation failed: \(error.localizedDescription)")
                    print("📝 Keeping mock data as fallback...")
                    // Mock data is already loaded, so no action needed
                }
            }
        }
    }
}
