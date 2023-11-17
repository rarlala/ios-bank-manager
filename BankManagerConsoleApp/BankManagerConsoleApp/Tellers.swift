import Foundation

struct Tellers {
    private let tellerCount: Int
    let tellerType: TypeOfWork
    let semaphore: DispatchSemaphore
    
    init(tellerCount: Int, tellerType: TypeOfWork) {
        self.tellerCount = tellerCount
        self.tellerType = tellerType
        self.semaphore = DispatchSemaphore(value: tellerCount)
    }
    
    func doTask(queue: Queue<Int>) {
        let name = tellerType.name
        let time = tellerType.time

        let group = DispatchGroup()
        
        print("queue \(queue.isEmpty())")
        while !queue.isEmpty () {
            print("queue \(queue.isEmpty())")
            guard let data = queue.dequeue() else { return }
            semaphore.wait()
            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                NotificationCenter.default.post(name: NSNotification.Name("RemoveReadyLabel"), object: "\(data) - \(name)")
                print("\(name) 은행원 \(data)번 고객 \(name)업무 시작")
                usleep(time)
                print("\(name) 은행원 \(data)번 고객 \(name)업무 완료")
                NotificationCenter.default.post(name: NSNotification.Name("RemoveRunningLabel"), object: "\(data) - \(name)")
                semaphore.signal()
                group.leave()
            }
        }
        group.wait()
    }
}
