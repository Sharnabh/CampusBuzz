import UIKit

class AudioRecordingView: UIView {
    
    // MARK: - UI Components
    private var backgroundView: UIView!
    private var waveformView: WaveformView!
    private var timeLabel: UILabel!
    private var recordButton: UIButton!
    private var cancelButton: UIButton!
    private var sendButton: UIButton!
    private var instructionLabel: UILabel!
    
    // MARK: - Properties
    weak var delegate: AudioRecordingViewDelegate?
    private var recordingTimer: Timer?
    private var recordingDuration: TimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Background blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        
        // Main container
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemBackground
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shadowOpacity = 0.3
        backgroundView.layer.shadowRadius = 8
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        
        // Waveform visualization
        waveformView = WaveformView()
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(waveformView)
        
        // Time label
        timeLabel = UILabel()
        timeLabel.text = "00:00"
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .label
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(timeLabel)
        
        // Instruction label
        instructionLabel = UILabel()
        instructionLabel.text = "Hold to record, release to send"
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(instructionLabel)
        
        // Record button
        recordButton = UIButton(type: .custom)
        recordButton.backgroundColor = .systemRed
        recordButton.layer.cornerRadius = 35
        recordButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        recordButton.tintColor = .white
        recordButton.imageView?.contentMode = .scaleAspectFit
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(recordButton)
        
        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(cancelButton)
        
        // Send button
        sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.systemBlue, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(sendButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Blur view
            subviews[0].topAnchor.constraint(equalTo: topAnchor),
            subviews[0].leadingAnchor.constraint(equalTo: leadingAnchor),
            subviews[0].trailingAnchor.constraint(equalTo: trailingAnchor),
            subviews[0].bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Background view
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 320),
            backgroundView.heightAnchor.constraint(equalToConstant: 280),
            
            // Time label
            timeLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24),
            timeLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            // Instruction label
            instructionLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            instructionLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            // Waveform view
            waveformView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            waveformView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            waveformView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            waveformView.heightAnchor.constraint(equalToConstant: 80),
            
            // Record button
            recordButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: 20),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Cancel button
            cancelButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
            
            // Send button
            sendButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            sendButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20),
            sendButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Public Methods
    
    func startRecording() {
        recordingDuration = 0
        updateTimeLabel()
        waveformView.startAnimating()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.recordingDuration += 0.1
            self?.updateTimeLabel()
            self?.waveformView.addAmplitude(Float.random(in: 0.1...1.0))
        }
        
        // Animate record button
        UIView.animate(withDuration: 0.3) {
            self.recordButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.recordButton.backgroundColor = .systemRed.withAlphaComponent(0.8)
        }
        
        // Enable send button after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.sendButton.isEnabled = true
            UIView.animate(withDuration: 0.2) {
                self.sendButton.alpha = 1.0
            }
        }
    }
    
    func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        waveformView.stopAnimating()
        
        UIView.animate(withDuration: 0.3) {
            self.recordButton.transform = .identity
            self.recordButton.backgroundColor = .systemRed
        }
    }
    
    func show(in parentView: UIView) {
        parentView.addSubview(self)
        frame = parentView.bounds
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    private func updateTimeLabel() {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        delegate?.audioRecordingViewDidCancel(self)
    }
    
    @objc private func sendTapped() {
        delegate?.audioRecordingViewDidSend(self, duration: recordingDuration)
    }
}

// MARK: - Waveform View

class WaveformView: UIView {
    
    private var amplitudes: [Float] = []
    private var isAnimating = false
    private var animationTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        isAnimating = true
        amplitudes.removeAll()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.setNeedsDisplay()
        }
    }
    
    func stopAnimating() {
        isAnimating = false
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    func addAmplitude(_ amplitude: Float) {
        amplitudes.append(amplitude)
        if amplitudes.count > 50 {
            amplitudes.removeFirst()
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.clear(rect)
        
        let barWidth: CGFloat = 4
        let barSpacing: CGFloat = 2
        let totalBarWidth = barWidth + barSpacing
        let numberOfBars = Int(rect.width / totalBarWidth)
        
        context.setFillColor(UIColor.systemBlue.cgColor)
        
        for i in 0..<numberOfBars {
            let x = CGFloat(i) * totalBarWidth
            let amplitude = i < amplitudes.count ? CGFloat(amplitudes[i]) : 0.1
            let height = rect.height * amplitude
            let y = (rect.height - height) / 2
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: height)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
            context.addPath(path.cgPath)
            context.fillPath()
        }
    }
}

// MARK: - Delegate Protocol

protocol AudioRecordingViewDelegate: AnyObject {
    func audioRecordingViewDidCancel(_ view: AudioRecordingView)
    func audioRecordingViewDidSend(_ view: AudioRecordingView, duration: TimeInterval)
}
