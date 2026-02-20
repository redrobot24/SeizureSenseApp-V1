import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate {

    static let shared = WatchConnectivityManager()

    override private init() {
        super.init()
        activate()
    }

    private func activate() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func send(bpm: Double) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["bpm": bpm], replyHandler: nil)
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
}
