//
//  HomeViewController.swift
//  CampusBuzz
//
//  Created by System on 21/06/25.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.refreshControl = refreshControl
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    // Navigation Bar Items
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "bell.badge"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        return button
    }()
    
    // Highlights Carousel
    private lazy var highlightsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 280, height: 120)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HighlightCardCell.self, forCellWithReuseIdentifier: "HighlightCardCell")
        return collectionView
    }()
    
    // Quick Access Shortcuts
    private lazy var quickAccessCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 90)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(QuickAccessCell.self, forCellWithReuseIdentifier: "QuickAccessCell")
        return collectionView
    }()
    
    // Live Group Activity Feed
    private lazy var liveGroupsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LiveGroupCell.self, forCellReuseIdentifier: "LiveGroupCell")
        return tableView
    }()
    
    // Upcoming Events
    private lazy var eventsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(EventCell.self, forCellReuseIdentifier: "EventCell")
        return tableView
    }()
    
    // Floating Action Button
    private lazy var floatingActionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .systemBlue
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(fabTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Data Sources
    
    private var highlights: [HighlightItem] = []
    private var quickAccessItems: [QuickAccessItem] = []
    private var liveGroups: [Group] = []
    private var upcomingEvents: [EventItem] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupDelegates()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "CampusBuzz"
        
        // Add main scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Add FAB
        view.addSubview(floatingActionButton)
        
        // Create section views
        setupHighlightsSection()
        setupQuickAccessSection()
        setupLiveGroupsSection()
        setupEventsSection()
        
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        // Left bar button (Profile)
        let profileBarButton = UIBarButtonItem(customView: profileButton)
        navigationItem.leftBarButtonItem = profileBarButton
        
        // Right bar buttons (Notifications and Refresh)
        let notificationBarButton = UIBarButtonItem(customView: notificationButton)
        let refreshBarButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
        navigationItem.rightBarButtonItems = [refreshBarButton, notificationBarButton]
        
        // Style navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupDelegates() {
        highlightsCollectionView.delegate = self
        highlightsCollectionView.dataSource = self
        
        quickAccessCollectionView.delegate = self
        quickAccessCollectionView.dataSource = self
        
        liveGroupsTableView.delegate = self
        liveGroupsTableView.dataSource = self
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
    }
    
    private func setupHighlightsSection() {
        let sectionLabel = createSectionLabel(text: "Campus Highlights")
        contentStackView.addArrangedSubview(sectionLabel)
        contentStackView.addArrangedSubview(highlightsCollectionView)
        highlightsCollectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    private func setupQuickAccessSection() {
        let sectionLabel = createSectionLabel(text: "Quick Access")
        contentStackView.addArrangedSubview(sectionLabel)
        contentStackView.addArrangedSubview(quickAccessCollectionView)
        quickAccessCollectionView.heightAnchor.constraint(equalToConstant: 90).isActive = true
    }
    
    private func setupLiveGroupsSection() {
        let sectionLabel = createSectionLabel(text: "Live Groups")
        let viewAllButton = createViewAllButton(action: #selector(viewAllLiveGroups))
        let headerStack = createSectionHeader(label: sectionLabel, button: viewAllButton)
        
        contentStackView.addArrangedSubview(headerStack)
        contentStackView.addArrangedSubview(liveGroupsTableView)
        liveGroupsTableView.heightAnchor.constraint(equalToConstant: 240).isActive = true // 3 cells * 80px
    }
    
    private func setupEventsSection() {
        let sectionLabel = createSectionLabel(text: "Upcoming Events")
        let viewAllButton = createViewAllButton(action: #selector(viewAllEvents))
        let headerStack = createSectionHeader(label: sectionLabel, button: viewAllButton)
        
        contentStackView.addArrangedSubview(headerStack)
        contentStackView.addArrangedSubview(eventsTableView)
        eventsTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true // 2 cells * 100px
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        return label
    }
    
    private func createViewAllButton(action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("View All", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func createSectionHeader(label: UILabel, button: UIButton) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content Stack View
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            
            // FAB
            floatingActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingActionButton.widthAnchor.constraint(equalToConstant: 56),
            floatingActionButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        loadHighlights()
        loadQuickAccessItems()
        loadLiveGroups()
        loadUpcomingEvents()
    }
    
    private func loadHighlights() {
        // Load announcements from Firebase
        FirebaseManager.shared.getAnnouncements { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let announcements):
                    self?.highlights = announcements.prefix(3).map { announcement in
                        HighlightItem(
                            title: announcement.title,
                            description: announcement.content,
                            imageURL: nil,
                            actionURL: nil
                        )
                    }
                    if self?.highlights.isEmpty ?? true {
                        self?.loadMockHighlights()
                    }
                case .failure(let error):
                    print("Failed to load announcements: \(error)")
                    self?.loadMockHighlights()
                }
                self?.highlightsCollectionView.reloadData()
            }
        }
    }
    
    private func loadMockHighlights() {
        // Mock data as fallback
        highlights = [
            HighlightItem(
                title: "Welcome to CampusBuzz!",
                description: "Connect with your campus community",
                imageURL: nil,
                actionURL: nil
            ),
            HighlightItem(
                title: "Join Study Groups",
                description: "Find your perfect study partners",
                imageURL: nil,
                actionURL: nil
            ),
            HighlightItem(
                title: "Upcoming Events",
                description: "Don't miss out on campus activities",
                imageURL: nil,
                actionURL: nil
            )
        ]
    }
    
    private func loadQuickAccessItems() {
        quickAccessItems = [
            QuickAccessItem(title: "Groups", icon: "person.3.fill", action: .groups),
            QuickAccessItem(title: "Events", icon: "calendar", action: .events),
            QuickAccessItem(title: "Polls", icon: "chart.bar.fill", action: .polls),
            QuickAccessItem(title: "Study", icon: "book.fill", action: .study),
            QuickAccessItem(title: "Market", icon: "bag.fill", action: .marketplace),
            QuickAccessItem(title: "Sports", icon: "sportscourt.fill", action: .sports)
        ]
        quickAccessCollectionView.reloadData()
    }
    
    private func loadLiveGroups() {
        // Use CometChatManager to fetch real groups
        CometChatManager.shared.fetchGroups { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    self?.liveGroups = Array(groups.prefix(3)) // Show only first 3
                    self?.liveGroupsTableView.reloadData()
                case .failure(let error):
                    print("Failed to load groups: \(error)")
                    // Use mock data as fallback
                    self?.loadMockGroups()
                }
            }
        }
    }
    
    private func loadMockGroups() {
        // Mock data as fallback
        liveGroups = []
        liveGroupsTableView.reloadData()
    }
    
    private func loadUpcomingEvents() {
        // Load events from Firebase
        FirebaseManager.shared.getEvents { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    // Convert CampusEvent to EventItem
                    self?.upcomingEvents = Array(events.prefix(3)).map { event in
                        EventItem(
                            title: event.title,
                            date: event.date,
                            location: event.location,
                            attendeeCount: event.attendees.count
                        )
                    }
                    if self?.upcomingEvents.isEmpty ?? true {
                        self?.loadMockEvents()
                    }
                case .failure(let error):
                    print("Failed to load events: \(error)")
                    self?.loadMockEvents()
                }
                self?.eventsTableView.reloadData()
            }
        }
    }
    
    private func loadMockEvents() {
        // Mock data as fallback
        upcomingEvents = [
            EventItem(
                title: "Welcome Orientation",
                date: Date().addingTimeInterval(86400), // Tomorrow
                location: "Main Auditorium",
                attendeeCount: 0
            ),
            EventItem(
                title: "Study Session",
                date: Date().addingTimeInterval(172800), // Day after tomorrow
                location: "Library Hall",
                attendeeCount: 0
            )
        ]
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        loadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func profileTapped() {
        // Navigate to profile
        print("Profile tapped")
    }
    
    @objc private func notificationTapped() {
        // Navigate to notifications
        print("Notifications tapped")
    }
    
    @objc private func viewAllLiveGroups() {
        // Navigate to groups tab/screen
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1 // Assuming groups is at index 1
        }
    }
    
    @objc private func viewAllEvents() {
        // Navigate to events screen
        print("View all events tapped")
    }
    
    @objc private func fabTapped() {
        let alertController = UIAlertController(title: "Create New", message: "What would you like to create?", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Post", style: .default) { _ in
            self.createPost()
        })
        
        alertController.addAction(UIAlertAction(title: "Event", style: .default) { _ in
            self.createEvent()
        })
        
        alertController.addAction(UIAlertAction(title: "Poll", style: .default) { _ in
            self.createPoll()
        })
        
        alertController.addAction(UIAlertAction(title: "Group", style: .default) { _ in
            self.createGroup()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func createPost() {
        print("Create post")
    }
    
    private func createEvent() {
        print("Create event")
    }
    
    private func createPoll() {
        print("Create poll")
    }
    
    private func createGroup() {
        print("Create group")
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == highlightsCollectionView {
            return highlights.count
        } else if collectionView == quickAccessCollectionView {
            return quickAccessItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == highlightsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HighlightCardCell", for: indexPath) as! HighlightCardCell
            cell.configure(with: highlights[indexPath.item])
            return cell
        } else if collectionView == quickAccessCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuickAccessCell", for: indexPath) as! QuickAccessCell
            cell.configure(with: quickAccessItems[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == quickAccessCollectionView {
            let item = quickAccessItems[indexPath.item]
            handleQuickAccessAction(item.action)
        }
    }
    
    private func handleQuickAccessAction(_ action: QuickAccessAction) {
        switch action {
        case .groups:
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 1
            }
        case .events:
            print("Navigate to events")
        case .polls:
            print("Navigate to polls")
        case .study:
            print("Navigate to study groups")
        case .marketplace:
            print("Navigate to marketplace")
        case .sports:
            print("Navigate to sports")
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == liveGroupsTableView {
            return liveGroups.count
        } else if tableView == eventsTableView {
            return upcomingEvents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == liveGroupsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LiveGroupCell", for: indexPath) as! LiveGroupCell
            cell.configure(with: liveGroups[indexPath.row])
            return cell
        } else if tableView == eventsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            cell.configure(with: upcomingEvents[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == liveGroupsTableView {
            return 80
        } else if tableView == eventsTableView {
            return 100
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == liveGroupsTableView {
            let group = liveGroups[indexPath.row]
            // Navigate to group chat
            print("Selected group: \(group.name ?? "Unknown")")
        } else if tableView == eventsTableView {
            let event = upcomingEvents[indexPath.row]
            // Navigate to event details
            print("Selected event: \(event.title)")
        }
    }
}
