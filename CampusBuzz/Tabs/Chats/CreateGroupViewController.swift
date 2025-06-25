import UIKit
import CometChatUIKitSwift
import CometChatSDK

class CreateGroupViewController: UIViewController {
    
    // MARK: - UI Components
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var groupImageView: UIImageView!
    private var groupNameTextField: UITextField!
    private var groupDescriptionTextView: UITextView!
    private var groupTypeSegmentedControl: UISegmentedControl!
    private var selectedUsersLabel: UILabel!
    private var createButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: CreateGroupDelegate?
    private var selectedImage: UIImage?
    private var selectedUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScrollView()
        setupFormElements()
        setupConstraints()
        updateSelectedUsersInfo()
    }
    
    // MARK: - Public Methods
    
    func setSelectedUsers(_ users: [User]) {
        self.selectedUsers = users
        if isViewLoaded {
            updateSelectedUsersInfo()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        updateTitle()
        view.backgroundColor = .systemBackground
        
        // Navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Create",
            style: .done,
            target: self,
            action: #selector(createTapped)
        )
        
        // Initially disable create button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func updateTitle() {
        if selectedUsers.isEmpty {
            title = "Create Group"
        } else {
            title = "Create Group (\(selectedUsers.count) users)"
        }
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupFormElements() {
        // Group image view
        groupImageView = UIImageView()
        groupImageView.image = UIImage(systemName: "person.3.fill")
        groupImageView.tintColor = .systemGray3
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.layer.cornerRadius = 50
        groupImageView.layer.masksToBounds = true
        groupImageView.backgroundColor = .systemGray6
        groupImageView.isUserInteractionEnabled = true
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(groupImageTapped))
        groupImageView.addGestureRecognizer(tapGesture)
        
        // Group name text field
        groupNameTextField = UITextField()
        groupNameTextField.placeholder = "Group Name"
        groupNameTextField.borderStyle = .roundedRect
        groupNameTextField.font = UIFont.systemFont(ofSize: 16)
        groupNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        groupNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Group description text view
        groupDescriptionTextView = UITextView()
        groupDescriptionTextView.text = "Group Description (Optional)"
        groupDescriptionTextView.textColor = .placeholderText
        groupDescriptionTextView.font = UIFont.systemFont(ofSize: 16)
        groupDescriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        groupDescriptionTextView.layer.borderWidth = 1
        groupDescriptionTextView.layer.cornerRadius = 8
        groupDescriptionTextView.delegate = self
        groupDescriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Group type segmented control
        groupTypeSegmentedControl = UISegmentedControl(items: ["Public", "Private", "Password Protected"])
        groupTypeSegmentedControl.selectedSegmentIndex = 0
        groupTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Selected users label
        selectedUsersLabel = UILabel()
        selectedUsersLabel.font = UIFont.systemFont(ofSize: 14)
        selectedUsersLabel.textColor = .secondaryLabel
        selectedUsersLabel.numberOfLines = 0
        selectedUsersLabel.text = "No users selected"
        selectedUsersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create button (alternative to nav bar button for better UX)
        createButton = UIButton(type: .system)
        createButton.setTitle("Create Group", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 12
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        createButton.isEnabled = false
        createButton.alpha = 0.6
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all elements to content view
        contentView.addSubview(groupImageView)
        contentView.addSubview(groupNameTextField)
        contentView.addSubview(groupDescriptionTextView)
        contentView.addSubview(groupTypeSegmentedControl)
        contentView.addSubview(selectedUsersLabel)
        contentView.addSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Group image
            groupImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            groupImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            groupImageView.widthAnchor.constraint(equalToConstant: 100),
            groupImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Group name
            groupNameTextField.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 32),
            groupNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            groupNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            groupNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Group description
            groupDescriptionTextView.topAnchor.constraint(equalTo: groupNameTextField.bottomAnchor, constant: 20),
            groupDescriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            groupDescriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            groupDescriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Group type
            groupTypeSegmentedControl.topAnchor.constraint(equalTo: groupDescriptionTextView.bottomAnchor, constant: 20),
            groupTypeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            groupTypeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            groupTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Selected users label
            selectedUsersLabel.topAnchor.constraint(equalTo: groupTypeSegmentedControl.bottomAnchor, constant: 20),
            selectedUsersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectedUsersLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Create button
            createButton.topAnchor.constraint(equalTo: selectedUsersLabel.bottomAnchor, constant: 40),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func updateSelectedUsersInfo() {
        updateTitle()
        
        if selectedUsers.isEmpty {
            selectedUsersLabel.text = "No users selected for this group"
        } else {
            let userNames = selectedUsers.compactMap { $0.name ?? $0.uid }.joined(separator: ", ")
            selectedUsersLabel.text = "Selected users (\(selectedUsers.count)): \(userNames)"
        }
    }
    
    private func updateCreateButtonState() {
        let isValid = !(groupNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        createButton.isEnabled = isValid
        navigationItem.rightBarButtonItem?.isEnabled = isValid
        
        UIView.animate(withDuration: 0.2) {
            self.createButton.alpha = isValid ? 1.0 : 0.6
        }
    }
    
    private func getGroupType() -> CometChat.groupType {
        switch groupTypeSegmentedControl.selectedSegmentIndex {
        case 0: return .public
        case 1: return .private
        case 2: return .password
        default: return .public
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard let groupName = groupNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !groupName.isEmpty else {
            showAlert(title: "Error", message: "Please enter a group name.")
            return
        }
        
        // Generate a unique GUID for the group
        let guid = "group_\(UUID().uuidString.lowercased())"
        let groupType = getGroupType()
        
        // Get description if provided
        let description = groupDescriptionTextView.textColor == .placeholderText ? 
            "" : groupDescriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Create group object
        let group = Group(guid: guid, name: groupName, groupType: groupType, password: nil)
        group.groupDescription = description.isEmpty ? nil : description
        
        // Show loading
        let loadingAlert = UIAlertController(title: "Creating Group", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        // Create group using CometChat
        CometChat.createGroup(group: group) { [weak self] createdGroup in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // If there are users to add, add them to the group
                if !self.selectedUsers.isEmpty {
                    self.addUsersToGroup(createdGroup, users: self.selectedUsers, loadingAlert: loadingAlert)
                } else {
                    // No users to add, just complete the creation
                    loadingAlert.dismiss(animated: true) {
                        self.delegate?.didCreateGroup(createdGroup)
                        self.dismiss(animated: true)
                    }
                }
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    self?.showAlert(title: "Error", message: "Failed to create group: \(error?.errorDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    @objc private func groupImageTapped() {
        let alert = UIAlertController(title: "Group Photo", message: "Choose an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure for iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = groupImageView
            popover.sourceRect = groupImageView.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func textFieldChanged() {
        updateCreateButtonState()
    }
    
    // MARK: - Helper Methods
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showAlert(title: "Error", message: "This feature is not available.")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func addUsersToGroup(_ group: Group, users: [User], loadingAlert: UIAlertController) {
        // Update loading message
        loadingAlert.message = "Adding users to group..."
        
        // Use CometChatManager to add members
        CometChatManager.shared.addMembersToGroup(groupGUID: group.guid, users: users) { [weak self] (result: Result<[String: Any]?, CometChatManagerError>) in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true, completion: {
                    switch result {
                    case .success(let response):
                        print("✅ Successfully added users to group. Response: \(response ?? [:])")
                        self?.delegate?.didCreateGroup(group)
                        self?.dismiss(animated: true)
                    case .failure(let error):
                        // Even if adding users fails, the group was created successfully
                        print("⚠️ Group created but failed to add some users: \(error)")
                        self?.delegate?.didCreateGroup(group)
                        self?.dismiss(animated: true)
                    }
                })
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension CreateGroupViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Group Description (Optional)"
            textView.textColor = .placeholderText
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension CreateGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            groupImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            groupImageView.image = originalImage
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - CreateGroupDelegate Protocol

protocol CreateGroupDelegate: AnyObject {
    func didCreateGroup(_ group: Group)
}
