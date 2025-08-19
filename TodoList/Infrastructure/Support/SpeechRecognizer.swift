import AVFoundation
import Foundation
import Speech

// Minimal speech recognizer helper for dictation into search field.
final class SystemSpeechRecognizer: NSObject, ObservableObject,
    SpeechRecognitionService {
    @Published var transcript: String = ""
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    private let localeIdentifier: String

    override init() {
        localeIdentifier =
            Locale.preferredLanguages.first ?? Locale.ruRU.identifier
        recognizer = SFSpeechRecognizer(
            locale: Locale(identifier: localeIdentifier)
        )
        super.init()
    }

    func start(onUpdate: @escaping (String) -> Void) {
        requestAuthorization { [weak self] granted in
            guard granted, let self else { return }
            DispatchQueue.main.async { self.begin(onUpdate: onUpdate) }
        }
    }

    func stop() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine = nil
    }

    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }

        AVAudioApplication.requestRecordPermission { permitted in
            if !permitted {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    private func begin(onUpdate: @escaping (String) -> Void) {
        stop()  // reset if needed
        let audioEngine = AVAudioEngine()
        self.audioEngine = audioEngine
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        guard let recognizer, recognizer.isAvailable else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .record,
                mode: .measurement,
                options: .duckOthers
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            return
        }

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                // Marshal UI-observable state changes to the main queue to avoid publishing from background threads.
                DispatchQueue.main.async {
                    self.transcript = text
                    onUpdate(text)
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async { self.stop() }
            }
        }

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(
            onBus: 0,
            bufferSize: AudioConstants.inputBufferSize,
            format: format
        ) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do { try audioEngine.start() } catch { stop() }
    }
}
