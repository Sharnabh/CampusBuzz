//
//  GroupCardCell.swift
//  CampusBuzz
//
//  Created by System on 25/06/25.
//

import UIKit
import CometChatSDK

class GroupCardCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let memberCountLabel = UILabel()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Container View
        contentView.addSubview(containerView)
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon Image View
        containerView.addSubview(iconImageView)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        iconImageView.layer.cornerRadius = 16
        iconImageView.image = UIImage(systemName: "person.3.fill")
        iconImageView.tintColor = UIColor.systemBlue
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Name Label
        containerView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        nameLabel.textColor = UIColor.label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Member Count Label
        containerView.addSubview(memberCountLabel)
        memberCountLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        memberCountLabel.textColor = UIColor.secondaryLabel
        memberCountLabel.textAlignment = .center
        memberCountLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Icon Image View
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            
            // Member Count Label
            memberCountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            memberCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            memberCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            memberCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with group: Group) {
        nameLabel.text = group.name
        memberCountLabel.text = "\(group.membersCount) members"
        
        // Load group icon if available
        if let iconURL = group.icon, !iconURL.isEmpty, let url = URL(string: iconURL) {
            loadImage(from: url)
        } else {
            // Use default icon based on group type or name
            iconImageView.image = UIImage(systemName: getGroupIcon(for: group))
            iconImageView.tintColor = getGroupColor(for: group)
        }
    }
    
    func configurePlaceholder(groupID: String) {
        nameLabel.text = "Loading..."
        memberCountLabel.text = ""
        iconImageView.image = UIImage(systemName: "person.3.fill")
        iconImageView.tintColor = UIColor.systemGray3
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.iconImageView.image = image
                    self?.iconImageView.contentMode = .scaleAspectFill
                } else {
                    // Fallback to default icon
                    self?.iconImageView.image = UIImage(systemName: "person.3.fill")
                    self?.iconImageView.tintColor = UIColor.systemBlue
                }
            }
        }.resume()
    }
    
    private func getGroupIcon(for group: Group) -> String {
        let groupName = group.name?.lowercased() ?? ""
        
        if groupName.contains("cse") || groupName.contains("computer") {
            return "laptopcomputer"
        } else if groupName.contains("gaming") || groupName.contains("game") {
            return "gamecontroller.fill"
        } else if groupName.contains("dsa") || groupName.contains("coding") {
            return "curlybraces"
        } else if groupName.contains("study") || groupName.contains("class") {
            return "book.fill"
        } else if groupName.contains("sports") || groupName.contains("fitness") {
            return "figure.run"
        } else if groupName.contains("music") || groupName.contains("band") {
            return "music.note"
        } else if groupName.contains("art") || groupName.contains("design") {
            return "paintbrush.fill"
        } else {
            return "person.3.fill"
        }
    }
    
    private func getGroupColor(for group: Group) -> UIColor {
        let groupName = group.name?.lowercased() ?? ""
        
        if groupName.contains("cse") || groupName.contains("computer") {
            return UIColor.systemBlue
        } else if groupName.contains("gaming") || groupName.contains("game") {
            return UIColor.systemPurple
        } else if groupName.contains("dsa") || groupName.contains("coding") {
            return UIColor.systemGreen
        } else if groupName.contains("study") || groupName.contains("class") {
            return UIColor.systemOrange
        } else if groupName.contains("sports") || groupName.contains("fitness") {
            return UIColor.systemRed
        } else if groupName.contains("music") || groupName.contains("band") {
            return UIColor.systemPink
        } else if groupName.contains("art") || groupName.contains("design") {
            return UIColor.systemTeal
        } else {
            return UIColor.systemBlue
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        nameLabel.text = nil
        memberCountLabel.text = nil
    }
}
