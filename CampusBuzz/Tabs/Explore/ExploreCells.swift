import UIKit
import CometChatSDK

// MARK: - Featured Group Cell

class FeaturedGroupCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .systemOrange
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.9)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join Now", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private var group: Group?
    var onJoinTapped: ((Group) -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(overlayView)
        containerView.addSubview(badgeLabel)
        containerView.addSubview(groupNameLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            badgeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            badgeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            groupNameLabel.topAnchor.constraint(equalTo: badgeLabel.bottomAnchor, constant: 8),
            groupNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            groupNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            joinButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            joinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            joinButton.heightAnchor.constraint(equalToConstant: 32),
            joinButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with group: Group) {
        self.group = group
        groupNameLabel.text = group.name
        descriptionLabel.text = group.groupDescription ?? "Join this amazing community!"
        
        // Set badge based on group properties
        if group.membersCount > 100 {
            badgeLabel.text = "🔥 Trending"
            badgeLabel.backgroundColor = .systemOrange
        } else if group.membersCount < 10 {
            badgeLabel.text = "✨ New"
            badgeLabel.backgroundColor = .systemGreen
        } else {
            badgeLabel.text = "💫 Featured"
            badgeLabel.backgroundColor = .systemPurple
        }
        
        // Set background gradient based on category
        setupBackgroundGradient(for: group.exploreCategory)
    }
    
    private func setupBackgroundGradient(for category: ExploreCategory) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 16
        
        switch category {
        case .academics:
            gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
        case .clubs:
            gradientLayer.colors = [UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
        case .sports:
            gradientLayer.colors = [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
        case .gaming:
            gradientLayer.colors = [UIColor.systemGreen.cgColor, UIColor.systemTeal.cgColor]
        case .career:
            gradientLayer.colors = [UIColor.systemIndigo.cgColor, UIColor.systemBlue.cgColor]
        case .dormLife:
            gradientLayer.colors = [UIColor.systemTeal.cgColor, UIColor.systemCyan.cgColor]
        default:
            gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        }
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        backgroundImageView.layer.sublayers?.removeAll()
        backgroundImageView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = backgroundImageView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundImageView.bounds
        }
    }
    
    // MARK: - Actions
    
    @objc private func joinButtonTapped() {
        guard let group = group else { return }
        onJoinTapped?(group)
    }
}

// MARK: - Category Filter Cell

class CategoryFilterCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    private var isSelectedState: Bool = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        
        // Create height constraint with lower priority
        let heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            heightConstraint
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with category: ExploreCategory, isSelected: Bool) {
        self.isSelectedState = isSelected
        
        // Extract emoji and text from display name
        let displayName = category.displayName
        let components = displayName.components(separatedBy: " ")
        if components.count > 1 {
            iconLabel.text = components[0] // First part should be emoji
            titleLabel.text = components.dropFirst().joined(separator: " ") // Rest is text
        } else {
            iconLabel.text = "🔍"
            titleLabel.text = displayName
        }
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        if isSelectedState {
            containerView.backgroundColor = .systemBlue
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            titleLabel.textColor = .white
        } else {
            containerView.backgroundColor = .secondarySystemBackground
            containerView.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = .label
        }
    }
    
    override var isSelected: Bool {
        didSet {
            isSelectedState = isSelected
            updateAppearance()
        }
    }
}

// MARK: - Explore Group Cell

class ExploreGroupCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var groupIconView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var groupIconLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var groupTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemGreen
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private var group: Group?
    var onJoinTapped: ((Group) -> Void)?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(groupIconView)
        groupIconView.addSubview(groupIconLabel)
        containerView.addSubview(groupNameLabel)
        containerView.addSubview(groupTypeLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(memberCountLabel)
        containerView.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            groupIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            groupIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            groupIconView.widthAnchor.constraint(equalToConstant: 48),
            groupIconView.heightAnchor.constraint(equalToConstant: 48),
            
            groupIconLabel.centerXAnchor.constraint(equalTo: groupIconView.centerXAnchor),
            groupIconLabel.centerYAnchor.constraint(equalTo: groupIconView.centerYAnchor),
            
            groupNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupIconView.trailingAnchor, constant: 12),
            
            groupTypeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            groupTypeLabel.leadingAnchor.constraint(equalTo: groupNameLabel.trailingAnchor, constant: 8),
            groupTypeLabel.heightAnchor.constraint(equalToConstant: 20),
            groupTypeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            descriptionLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: groupIconView.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: joinButton.leadingAnchor, constant: -12),
            
            memberCountLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2),
            memberCountLabel.leadingAnchor.constraint(equalTo: groupIconView.trailingAnchor, constant: 12),
            memberCountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            joinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            joinButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            joinButton.heightAnchor.constraint(equalToConstant: 32),
            joinButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with group: Group) {
        self.group = group
        
        groupNameLabel.text = group.name
        groupIconLabel.text = group.firstLetterForIcon
        descriptionLabel.text = group.groupDescription ?? "Join this group to start chatting!"
        memberCountLabel.text = "👥 \(group.memberCountText)"
        
        // Configure group type label
        groupTypeLabel.text = group.groupTypeDisplayText
        switch group.groupType {
        case .public:
            groupTypeLabel.backgroundColor = .systemGreen
        case .private:
            groupTypeLabel.backgroundColor = .systemOrange
        case .password:
            groupTypeLabel.backgroundColor = .systemRed
        @unknown default:
            groupTypeLabel.backgroundColor = .systemGray
        }
        
        // Set icon color based on category
        let category = group.exploreCategory
        switch category {
        case .academics:
            groupIconView.backgroundColor = .systemBlue
        case .clubs:
            groupIconView.backgroundColor = .systemPurple
        case .sports:
            groupIconView.backgroundColor = .systemOrange
        case .gaming:
            groupIconView.backgroundColor = .systemGreen
        case .career:
            groupIconView.backgroundColor = .systemIndigo
        case .dormLife:
            groupIconView.backgroundColor = .systemTeal
        default:
            groupIconView.backgroundColor = .systemBlue
        }
    }
    
    // MARK: - Actions
    
    @objc private func joinButtonTapped() {
        guard let group = group else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Update button temporarily
        joinButton.setTitle("Joining...", for: .normal)
        joinButton.isEnabled = false
        
        onJoinTapped?(group)
        
        // Reset button after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.joinButton.setTitle("Join", for: .normal)
            self.joinButton.isEnabled = true
        }
    }
}

// MARK: - Suggested Group Cell

class SuggestedGroupCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var reasonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private var group: Group?
    var onJoinTapped: ((Group) -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(groupNameLabel)
        containerView.addSubview(reasonLabel)
        containerView.addSubview(memberCountLabel)
        containerView.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            groupNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            groupNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            groupNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            reasonLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 4),
            reasonLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            reasonLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            memberCountLabel.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 4),
            memberCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            joinButton.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 4),
            joinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            joinButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            joinButton.heightAnchor.constraint(equalToConstant: 24),
            joinButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with group: Group) {
        self.group = group
        
        groupNameLabel.text = group.name
        memberCountLabel.text = "👥 \(group.memberCountText)"
        
        // Generate a suggested reason based on group category
        let category = group.exploreCategory
        switch category {
        case .academics:
            reasonLabel.text = "📚 Based on your academic interests"
        case .clubs:
            reasonLabel.text = "🎭 Because you like club activities"
        case .sports:
            reasonLabel.text = "🏋️‍♂️ Perfect for sports enthusiasts"
        case .gaming:
            reasonLabel.text = "🎮 For gaming community lovers"
        case .career:
            reasonLabel.text = "💼 Career-focused recommendation"
        case .dormLife:
            reasonLabel.text = "🛏️ Great for campus life"
        default:
            reasonLabel.text = "✨ Recommended for you"
        }
    }
    
    // MARK: - Actions
    
    @objc private func joinButtonTapped() {
        guard let group = group else { return }
        onJoinTapped?(group)
    }
}
