import Foundation

public typealias AsyncStateUpdate<S, P> = (S) -> (S, P)

class AsyncState<S, P> {
    private let queue: DispatchQueue
    
    public let notifier = Notifier<P>()
    public private(set) var current: S
    
    public init(state: S, queue: DispatchQueue) {
        self.current = state
        self.queue = queue
    }
    
    public func process(_ f: @escaping AsyncStateUpdate<S,P>) {
        assert(Thread.isMainThread)
        queue.async {
            let (newState, payload) = f(self.current)
            DispatchQueue.main.sync {
                self.current = newState
                self.notifier.notify(payload)
            }
        }
    }
}
