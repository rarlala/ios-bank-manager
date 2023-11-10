import Foundation

struct Tellers {
    private let tellerCount: Int
    private let tellerType: TypeOfWork
    
    init(tellerCount: Int, tellerType: TypeOfWork) {
        self.tellerCount = tellerCount
        self.tellerType = tellerType
    }
    
    func doTask(queue: Queue<Int>) {
        let name = tellerType.name
        let time = tellerType.time
        
        let semaphore = DispatchSemaphore(value: tellerCount)
        let group = DispatchGroup()
        
        while !queue.isEmpty() {
            
            guard let data = queue.dequeue() else { return }
            
            semaphore.wait()
            group.enter()
            DispatchQueue.global().async {
                print("\(name) 은행원 \(data)번 고객 \(name)업무 시작")
                usleep(time)
                print("\(name) 은행원 \(data)번 고객 \(name)업무 완료")
                semaphore.signal()
                group.leave()
            }
        }
        group.wait()
    }
}
