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
        self.willBeginCallbacks.forEach { $0() }
    }

    func transitionDidEnd() {
        self.didEndCallbacks.forEach { $0() }
    }
}