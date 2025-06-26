//
//  EditProfileViewController.swift
//  CampusBuzz
//
//  Created by System on 25/06/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class EditProfileViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView = UIImageView()
    private let changePhotoButton = UIButton()
    
    private let fullNameTextField = UITextField()
    private let courseTextField = UITextField()
    private let yearPickerView = UIPickerView()
    private let yearTextField = UITextField()
    private let collegeIDTextField = UITextField()
    
    private let saveButton = UIButton()
    
    // MARK: - Properties
    
    var userProfile: [String: Any] = [:]
    weak var delegate: EditProfileDelegate?
    
    private let years = ["1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year", "Graduate", "Post Graduate"]
    private var selectedImage: UIImage?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupConstraints()
        populateFields()
        setupKeyboardHandling()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        setupScrollView()
        setupProfileImageSection()
        setupFormFields()
        setupSaveButton()
    }
    
    private func setupNavigationBar() {
        title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
    }
    
    private func setupProfileImageSection() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(changePhotoButton)
        
        // Profile Image View
        profileImageView.layer.cornerRadius = 60
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.systemBlue.cgColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.systemGray5
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = UIColor.systemGray3
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Change Photo Button
        changePhotoButton.setTitle("Change Photo", for: .normal)
        changePhotoButton.setTitleColor(UIColor.systemBlue, for: .normal)
        changePhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupFormFields() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        // Full Name Field
        let fullNameContainer = createFieldContainer(
            title: "Full Name",
            textField: fullNameTextField,
            placeholder: "Enter your full name"
        )
        fullNameTextField.textContentType = .name
        fullNameTextField.autocapitalizationType = .words
        
        // Course Field
        let courseContainer = createFieldContainer(
            title: "Course",
            textField: courseTextField,
            placeholder: "e.g., B.Tech CSE"
        )
        courseTextField.autocapitalizationType = .words
        
        // Year Field
        let yearContainer = createFieldContainer(
            title: "Year",
            textField: yearTextField,
            placeholder: "Select your year"
        )
        setupYearPicker()
        
        // College ID Field
        let collegeIDContainer = createFieldContainer(
            title: "College ID",
            textField: collegeIDTextField,
            placeholder: "e.g., 21CSE102"
        )
        collegeIDTextField.autocapitalizationType = .allCharacters
        
        stackView.addArrangedSubview(fullNameContainer)
        stackView.addArrangedSubview(courseContainer)
        stackView.addArrangedSubview(yearContainer)
        stackView.addArrangedSubview(collegeIDContainer)
        
        // Stack View Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func createFieldContainer(title: String, textField: UITextField, placeholder: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 12
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(textField)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 48),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupYearPicker() {
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        yearTextField.inputView = yearPickerView
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(yearPickerDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [flexSpace, doneButton]
        yearTextField.inputAccessoryView = toolbar
    }
    
    private func setupSaveButton() {
        contentView.addSubview(saveButton)
        
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.layer.cornerRadius = 12
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Profile Image View
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Change Photo Button
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Save Button
            saveButton.topAnchor.constraint(greaterThanOrEqualTo: collegeIDTextField.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Data Population
    
    private func populateFields() {
        fullNameTextField.text = userProfile["fullName"] as? String ?? ""
        courseTextField.text = userProfile["course"] as? String ?? ""
        collegeIDTextField.text = userProfile["collegeID"] as? String ?? ""
        
        if let year = userProfile["year"] as? String {
            yearTextField.text = year
            if let index = years.firstIndex(of: year) {
                yearPickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        // Load existing profile image
        if let imageUrlString = userProfile["profileImageURL"] as? String,
           let imageUrl = URL(string: imageUrlString) {
            loadProfileImage(from: imageUrl)
        }
    }
    
    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.profileImageView.image = image
                    self?.profileImageView.contentMode = .scaleAspectFill
                }
            }
        }.resume()
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func changePhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc private func yearPickerDone() {
        yearTextField.resignFirstResponder()
    }
    
    @objc private func saveButtonTapped() {
        guard validateFields() else { return }
        
        saveButton.isEnabled = false
        saveButton.setTitle("Saving...", for: .normal)
        
        saveProfile()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation & Saving
    
    private func validateFields() -> Bool {
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
            showError("Please enter your full name")
            return false
        }
        
        guard let course = courseTextField.text, !course.isEmpty else {
            showError("Please enter your course")
            return false
        }
        
        guard let year = yearTextField.text, !year.isEmpty else {
            showError("Please select your year")
            return false
        }
        
        return true
    }
    
    private func saveProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let profileData: [String: Any] = [
            "fullName": fullNameTextField.text ?? "",
            "course": courseTextField.text ?? "",
            "year": yearTextField.text ?? "",
            "collegeID": collegeIDTextField.text ?? "",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // If there's a new image, upload it first
        if let selectedImage = selectedImage {
            uploadProfileImage(selectedImage) { [weak self] imageURL in
                var updatedData = profileData
                if let imageURL = imageURL {
                    updatedData["profileImageURL"] = imageURL
                }
                self?.saveToFirestore(data: updatedData, userID: currentUser.uid)
            }
        } else {
            saveToFirestore(data: profileData, userID: currentUser.uid)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(currentUser.uid).jpg")
        
        profileImageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    private func saveToFirestore(data: [String: Any], userID: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).setData(data, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                self?.saveButton.isEnabled = true
                self?.saveButton.setTitle("Save Changes", for: .normal)
                
                if let error = error {
                    self?.showError("Failed to save profile: \(error.localizedDescription)")
                } else {
                    self?.delegate?.didUpdateProfile()
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIPickerView DataSource & Delegate

extension EditProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return years[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        yearTextField.text = years[row]
    }
}

// MARK: - UIImagePickerController Delegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        self.selectedImage = selectedImage
        profileImageView.image = selectedImage
        profileImageView.contentMode = .scaleAspectFill
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
