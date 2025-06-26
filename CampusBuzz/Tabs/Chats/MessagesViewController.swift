import UIKit
import CometChatUIKitSwift
import CometChatSDK
import AVFoundation
import Photos
import PhotosUI

class MessagesViewController: UIViewController {
    
    // MARK: - Properties
    private var messageList: CometChatMessageList!
    private var messageComposer: CometChatMessageComposer!
    private var user: User?
    private var group: Group?
    private var receiverType: CometChat.ReceiverType = .user
    
    // Audio recording properties
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession!
    private var audioRecordingURL: URL?
    
    // Recording UI
    private var audioRecordingView: AudioRecordingView?
    
    // Attachment handling
    private var imagePicker: UIImagePickerController?
    
    // Recording timer property
    private var recordingTimer: Timer?
    private var recordingDuration: TimeInterval = 0
    
    // MARK: - Initialization
    
    init(user: User) {
        self.user = user
        self.receiverType = .user
        super.init(nibName: nil, bundle: nil)
    }
    
    init(group: Group) {
        self.group = group
        self.receiverType = .group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        setupMessageList()
        
        // Add error handling for CometChat framework issues
        setupErrorHandling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Try to find and hide the default attachment button to prevent framework issues
        hideDefaultAttachmentButton()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure navigation bar
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureNavigationBar() {
        if let user = user {
            title = user.name ?? user.uid
        } else if let group = group {
            title = group.name
        }
        
        // Add attachment button to navigation bar
        let attachmentButton = UIBarButtonItem(
            image: UIImage(systemName: "paperclip"),
            style: .plain,
            target: self,
            action: #selector(attachmentButtonTapped)
        )
        navigationItem.rightBarButtonItem = attachmentButton
        
        // Add back button functionality
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    @objc private func attachmentButtonTapped() {
        showAttachmentOptions()
    }
    
    private func setupAudioSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        self?.showPermissionAlert()
                    }
                }
            }
        } catch {
            print("Failed to set up recording session: \(error)")
        }
    }
    
    private func setupMessageList() {
        // Create the message list view
        messageList = CometChatMessageList()
        messageList.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the message composer view
        messageComposer = CometChatMessageComposer()
        messageComposer.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure both components based on receiver type
        if let user = user {
            messageList.set(user: user)
            messageComposer.set(user: user)
        } else if let group = group {
            messageList.set(group: group)
            messageComposer.set(group: group)
        }
        
        // Add to view hierarchy
        view.addSubview(messageList)
        view.addSubview(messageComposer)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Message list constraints (takes most of the space)
            messageList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageList.bottomAnchor.constraint(equalTo: messageComposer.topAnchor),
            
            // Message composer constraints (bottom of screen)
            messageComposer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageComposer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageComposer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func set(conversationWith user: User, type: CometChat.ReceiverType) {
        self.user = user
        self.receiverType = type
        
        if isViewLoaded {
            messageList?.set(user: user)
            messageComposer?.set(user: user)
            title = user.name ?? user.uid
        }
    }
    
    func set(conversationWith group: Group, type: CometChat.ReceiverType) {
        self.group = group
        self.receiverType = type
        
        if isViewLoaded {
            messageList?.set(group: group)
            messageComposer?.set(group: group)
            title = group.name
        }
    }
}

// MARK: - Factory Methods

extension MessagesViewController {
    
    static func create(for user: User) -> MessagesViewController {
        let messagesVC = MessagesViewController(user: user)
        return messagesVC
    }
    
    static func create(for group: Group) -> MessagesViewController {
        let messagesVC = MessagesViewController(group: group)
        return messagesVC
    }
}


// MARK: - Audio Recording Methods

extension MessagesViewController {
    
    private func startAudioRecording() {
        // Check permission
        guard recordingSession.recordPermission == .granted else {
            requestRecordingPermission()
            return
        }
        
        // Create recording URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioRecordingURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        guard let url = audioRecordingURL else { return }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            showRecordingUI()
            startRecordingTimer()
            
        } catch {
            print("Could not start recording: \(error)")
            showAlert(title: "Recording Error", message: "Failed to start recording.")
        }
    }
    
    private func stopAudioRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        hideRecordingUI()
        stopRecordingTimer()
        
        // Send the recorded audio
        if let audioURL = audioRecordingURL {
            sendAudioMessage(url: audioURL, duration: 0)
        }
    }
    
    private func finishRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    private func cancelAudioRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        hideRecordingUI()
        stopRecordingTimer()
        
        // Delete the recorded file
        if let audioURL = audioRecordingURL {
            try? FileManager.default.removeItem(at: audioURL)
        }
    }
    
    private func showRecordingUI() {
        guard audioRecordingView == nil else { return }
        
        audioRecordingView = AudioRecordingView()
        audioRecordingView?.delegate = self
        audioRecordingView?.show(in: view)
        audioRecordingView?.startRecording()
    }
    
    private func hideRecordingUI() {
        audioRecordingView?.stopRecording()
        audioRecordingView?.hide()
        audioRecordingView = nil
    }
    
    private func requestRecordingPermission() {
        recordingSession.requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self?.startAudioRecording()
                } else {
                    self?.showPermissionAlert()
                }
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone Permission Required",
            message: "Please allow microphone access to record audio messages.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Timer Methods

extension MessagesViewController {
    
    private func startRecordingTimer() {
        recordingDuration = 0
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.recordingDuration += 0.1
            self?.updateRecordingTime()
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    private func updateRecordingTime() {
        // AudioRecordingView manages its own timer and UI updates
    }
}

// MARK: - Attachment Methods

extension MessagesViewController {
    
    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Not Available", message: "Camera is not available on this device.")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func presentPhotoLibrary() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .any(of: [.images, .videos])
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image", "public.movie"]
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
        }
    }
    
    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    private func shareLocation() {
        // Implement location sharing
        showAlert(title: "Location Sharing", message: "Location sharing will be implemented in a future update.")
    }
}

// MARK: - Message Sending Methods

extension MessagesViewController {
    
    private func sendImageMessage(image: UIImage) {
        // Convert image to data and send
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileName = "image_\(Date().timeIntervalSince1970).jpg"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: tempURL)
            sendMediaMessage(url: tempURL, messageType: .image)
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    private func sendVideoMessage(url: URL) {
        sendMediaMessage(url: url, messageType: .video)
    }
    
    private func sendAudioMessage(url: URL) {
        sendMediaMessage(url: url, messageType: .audio)
    }
    
    private func sendDocumentMessage(url: URL) {
        sendMediaMessage(url: url, messageType: .file)
    }
    
    private func sendMediaMessage(url: URL, messageType: CometChat.MessageType) {
        let receiverID: String
        let receiverType: CometChat.ReceiverType
        
        if let user = user {
            receiverID = user.uid ?? ""
            receiverType = .user
        } else if let group = group {
            receiverID = group.guid
            receiverType = .group
        } else {
            return
        }
        
        let mediaMessage = MediaMessage(
            receiverUid: receiverID,
            fileurl: url.absoluteString,
            messageType: messageType,
            receiverType: receiverType
        )
        
        CometChat.sendMediaMessage(message: mediaMessage) { message in
            print("✅ Media message sent successfully")
        } onError: { error in
            print("❌ Failed to send media message: \(error?.errorDescription ?? "Unknown error")")
        }
    }
    
    private func sendAudioMessage(url: URL, duration: TimeInterval) {
        let receiverID: String
        let receiverType: CometChat.ReceiverType
        
        if let user = user {
            receiverID = user.uid ?? ""
            receiverType = .user
        } else if let group = group {
            receiverID = group.guid
            receiverType = .group
        } else {
            return
        }
        
        let mediaMessage = MediaMessage(
            receiverUid: receiverID,
            fileurl: url.absoluteString,
            messageType: .audio,
            receiverType: receiverType
        )
        
        CometChat.sendMediaMessage(message: mediaMessage) { message in
            print("✅ Audio message sent successfully")
            DispatchQueue.main.async {
                // The message will appear automatically in the message list
            }
        } onError: { error in
            print("❌ Failed to send audio message: \(error?.errorDescription ?? "Unknown error")")
            DispatchQueue.main.async {
                self.showAlert(title: "Failed to Send", message: "Could not send the audio message.")
            }
        }
    }
}

// MARK: - Helper Methods

extension MessagesViewController {
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVAudioRecorderDelegate

extension MessagesViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("✅ Audio recording completed successfully")
        } else {
            print("❌ Audio recording failed")
            showAlert(title: "Recording Failed", message: "Failed to complete audio recording.")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("❌ Audio recording error: \(error?.localizedDescription ?? "Unknown error")")
        hideRecordingUI()
        stopRecordingTimer()
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension MessagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            sendImageMessage(image: image)
        } else if let videoURL = info[.mediaURL] as? URL {
            sendVideoMessage(url: videoURL)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14.0, *)
extension MessagesViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        // Handle images
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.sendImageMessage(image: image)
                    }
                }
            }
        }
        // Handle videos
        else if result.itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { [weak self] url, error in
                DispatchQueue.main.async {
                    if let url = url {
                        // Copy to temporary location since the original URL might be deleted
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("video_\(Date().timeIntervalSince1970).mp4")
                        do {
                            try FileManager.default.copyItem(at: url, to: tempURL)
                            self?.sendVideoMessage(url: tempURL)
                        } catch {
                            print("Failed to copy video: \(error)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension MessagesViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            showAlert(title: "Access Denied", message: "Cannot access the selected document.")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // Copy to temporary location
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            try FileManager.default.copyItem(at: url, to: tempURL)
            sendDocumentMessage(url: tempURL)
        } catch {
            print("Failed to copy document: \(error)")
            showAlert(title: "Error", message: "Failed to process the selected document.")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // User cancelled the picker
    }
}

// MARK: - AudioRecordingViewDelegate

extension MessagesViewController: AudioRecordingViewDelegate {
    func audioRecordingViewDidCancel(_ view: AudioRecordingView) {
        stopAudioRecording()
        hideRecordingUI()
    }
    
    func audioRecordingViewDidSend(_ view: AudioRecordingView, duration: TimeInterval) {
        finishRecording()
        hideRecordingUI()
        
        // Send the recorded audio
        if let recordingURL = audioRecordingURL {
            sendAudioMessage(url: recordingURL, duration: duration)
        }
    }
}

// MARK: - Custom Attachment Button

extension MessagesViewController {
    private func showAttachmentOptions() {
        let actionSheet = UIAlertController(title: "Attach Media", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.presentCamera()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentPhotoLibrary()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Document", style: .default) { _ in
            self.presentDocumentPicker()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Audio Recording", style: .default) { _ in
            self.startAudioRecording()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure for iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(actionSheet, animated: true)
    }
    
    private func hideDefaultAttachmentButton() {
        // Recursively search for attachment buttons in the message composer
        findAndHideAttachmentButtons(in: messageComposer)
    }
    
    private func findAndHideAttachmentButtons(in view: UIView) {
        for subview in view.subviews {
            // Look for buttons that might be attachment buttons
            if let button = subview as? UIButton {
                // Check if this looks like an attachment button
                if button.imageView?.image != nil || 
                   button.titleLabel?.text?.contains("attach") == true ||
                   button.accessibilityLabel?.contains("attach") == true {
                    button.isHidden = true
                    button.isUserInteractionEnabled = false
                }
            }
            // Recursively search subviews
            findAndHideAttachmentButtons(in: subview)
        }
    }
}

// MARK: - Error Handling

extension MessagesViewController {
    
    private func setupErrorHandling() {
        // Set up global error handling to catch framework issues
        NSSetUncaughtExceptionHandler { exception in
            print("🚨 Uncaught exception: \(exception)")
            print("🚨 Exception reason: \(exception.reason ?? "Unknown")")
        }
    }
}
