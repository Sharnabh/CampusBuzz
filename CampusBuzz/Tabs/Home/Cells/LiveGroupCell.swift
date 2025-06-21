//
//  LiveGroupCell.swift
//  CampusBuzz
//
//  Created by System on 21/06/25.
//

import UIKit
import CometChatSDK

class LiveGroupCell: UITableViewCell {
    
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
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var groupIconLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
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
    
    private lazy var memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var onlineIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var unreadBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        containerView.addSubview(memberCountLabel)
        containerView.addSubview(lastMessageLabel)
        containerView.addSubview(onlineIndicatorView)
        containerView.addSubview(unreadBadge)
        unreadBadge.addSubview(unreadCountLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            groupIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            groupIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            groupIconView.widthAnchor.constraint(equalToConstant: 40),
            groupIconView.heightAnchor.constraint(equalToConstant: 40),
            
            groupIconLabel.centerXAnchor.constraint(equalTo: groupIconView.centerXAnchor),
            groupIconLabel.centerYAnchor.constraint(equalTo: groupIconView.centerYAnchor),
            
            groupNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            groupNameLabel.leadingAnchor.constraint(equalTo: groupIconView.trailingAnchor, constant: 12),
            groupNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: unreadBadge.leadingAnchor, constant: -8),
            
            memberCountLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 2),
            memberCountLabel.leadingAnchor.constraint(equalTo: groupIconView.trailingAnchor, constant: 12),
            
            lastMessageLabel.topAnchor.constraint(equalTo: memberCountLabel.bottomAnchor, constant: 2),
            lastMessageLabel.leadingAnchor.constraint(equalTo: groupIconView.trailingAnchor, constant: 12),
            lastMessageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            lastMessageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            onlineIndicatorView.trailingAnchor.constraint(equalTo: groupIconView.trailingAnchor, constant: 2),
            onlineIndicatorView.bottomAnchor.constraint(equalTo: groupIconView.bottomAnchor, constant: 2),
            onlineIndicatorView.widthAnchor.constraint(equalToConstant: 8),
            onlineIndicatorView.heightAnchor.constraint(equalToConstant: 8),
            
            unreadBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            unreadBadge.centerYAnchor.constraint(equalTo: groupNameLabel.centerYAnchor),
            unreadBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            unreadBadge.heightAnchor.constraint(equalToConstant: 16),
            
            unreadCountLabel.centerXAnchor.constraint(equalTo: unreadBadge.centerXAnchor),
            unreadCountLabel.centerYAnchor.constraint(equalTo: unreadBadge.centerYAnchor),
            unreadCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: unreadBadge.leadingAnchor, constant: 4),
            unreadCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: unreadBadge.trailingAnchor, constant: -4)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with group: Group) {
        groupNameLabel.text = group.name
        
        // Create group icon from first letter of name
        let firstLetter = String(group.name?.first ?? "G").uppercased()
        groupIconLabel.text = firstLetter
        
        // Set member count
        memberCountLabel.text = "\(group.membersCount) members"
        
        // Mock last message for demo
        lastMessageLabel.text = "Active now"
        
        // Show online indicator for demo
        onlineIndicatorView.isHidden = false
        
        // Mock unread count for demo (you can implement real logic later)
        let mockUnreadCount = Int.random(in: 0...5)
        if mockUnreadCount > 0 {
            unreadBadge.isHidden = false
            unreadCountLabel.text = "\(mockUnreadCount)"
        } else {
            unreadBadge.isHidden = true
        }
    }
}
