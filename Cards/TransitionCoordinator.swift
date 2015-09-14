import Foundation

public class TransitionCoordinator {
    var willBeginCallbacks: [() -> Void] = []
    var didEndCallbacks: [() -> Void] = []

    public func notifyWhenTransitionWillBegin(callback: () -> Void) {
        self.willBeginCallbacks.append(callback)
    }

    public func notifyWhenTransitionDidEnd(callback: () -> Void) {
        self.didEndCallbacks.append(callback)
    }

    func transitionWillBegin() {
        willBeginCallbacks.map { $0() }
    }

    func transitionDidEnd() {
        didEndCallbacks.map { $0() }
    }
}