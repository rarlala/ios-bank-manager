import Foundation

final class BankManager {
    private let customerCount: Int
    private let depositTellers: Tellers
    private let loanTellers: Tellers
    let depositCustomerQueue = Queue<Int>()
    let loanCustomerQueue = Queue<Int>()
    private var startTime: Date?
    var totalCustomer: Int = 0
    var currentStatus: Status = .allStop
    
    var count = 0
    
    enum Status {
        case allStop, depositStop, loanStop, run
    }
    
    var timer = Timer()
    
    init(depositTellerCount: Int, loanTellerCount: Int) {
        self.customerCount = Int.random(in: 10...30)
        self.depositTellers = Tellers(tellerCount: depositTellerCount, tellerType: .Deposit)
        self.loanTellers = Tellers(tellerCount: loanTellerCount, tellerType: .Loan)
    }
    
    func openBank() {
        startTime = Date()
        createCustomerQueue(customerCount: customerCount)
        startTask()
    }
    
    func startTask() {
        let depositWork = (depositTellers, depositCustomerQueue)
        let loanWork = (loanTellers, loanCustomerQueue)

        let group = DispatchGroup()
        count += 1
        
        [depositWork, loanWork].forEach { (tellers, queue) in
            group.enter()
            DispatchQueue.global().async {

                tellers.doTask(queue: queue)
                group.leave()
            }
        }
        
        group.wait()
        count -= 1
        print("group out \(count)")
        
        // dispatchQueue -> startTask
            // 호출될 때마다 group이 새로 생성
            // DispatchQueue에 스레드가 추가되어 해당 작업을 처리
                // 근데 모든 큐가 빌때까지 실행됨
                // -> 그래서 CPU가 올라간다.
        
                // 큐가 비면 순차적으로 해제됨
            
        // semaphore 예금 2, 대출 1 제한

        // 그룹, 그룹, 그룹, 그룹, 그룹
        // 큐에 동시 접근
            // 누군가는 뽑았음
            // 누군가는 뽑지 못함
        
    }
    
    func finishTask() {
        let endTime = Date()
        guard let startTime = startTime else { return }
        let time = endTime.timeIntervalSince(startTime)
        let totalSecond = String(format: "%.2f", time)
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(customerCount)명이며, 총 업무시간은 \(totalSecond)초 입니다.")
    }
    
    func createCustomerQueue(customerCount: Int) {
        for n in 1...customerCount {
            guard let work = TypeOfWork(rawValue: Int.random(in: 0...1)) else {
                return
            }
            
            switch work {
            case .Deposit:
                depositCustomerQueue.enqueue(data: totalCustomer + n)
                NotificationCenter.default.post(name: NSNotification.Name("AddDepositLabel"), object: self.totalCustomer + n)
            case .Loan:
                loanCustomerQueue.enqueue(data: totalCustomer + n)
                NotificationCenter.default.post(name: NSNotification.Name("AddLoanLabel"), object: self.totalCustomer + n)
            }
        }
    }
}
