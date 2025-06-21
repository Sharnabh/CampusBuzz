//
//  EventCell.swift
//  CampusBuzz
//
//  Created by System on 21/06/25.
//

import UIKit

class EventCell: UITableViewCell {
    
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
    
    private lazy var dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var eventTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var attendeeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
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
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        containerView.addSubview(dateStackView)
        dateStackView.addArrangedSubview(monthLabel)
        dateStackView.addArrangedSubview(dayLabel)
        containerView.addSubview(eventTitleLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(attendeeLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            dateStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            dateStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dateStackView.widthAnchor.constraint(equalToConstant: 50),
            
            eventTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            eventTitleLabel.leadingAnchor.constraint(equalTo: dateStackView.trailingAnchor, constant: 12),
            eventTitleLabel.trailingAnchor.constraint(equalTo: joinButton.leadingAnchor, constant: -8),
            
            locationLabel.topAnchor.constraint(equalTo: eventTitleLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: dateStackView.trailingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: joinButton.leadingAnchor, constant: -8),
            
            attendeeLabel.leadingAnchor.constraint(equalTo: dateStackView.trailingAnchor, constant: 12),
            attendeeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            timeLabel.trailingAnchor.constraint(equalTo: joinButton.leadingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            joinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            joinButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 60),
            joinButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with event: EventItem) {
        eventTitleLabel.text = event.title
        locationLabel.text = "📍 \(event.location)"
        attendeeLabel.text = "\(event.attendeeCount) attending"
        
        // Format date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        monthLabel.text = formatter.string(from: event.date).uppercased()
        
        formatter.dateFormat = "dd"
        dayLabel.text = formatter.string(from: event.date)
        
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: event.date)
    }
}
