# 은행창구 관리앱 
은행창구의 고객 대기열을 UI와 콘솔로 처리화면을 보여주는 앱 


## 콘솔 작동 화면
![aaaa](https://hackmd.io/_uploads/Sy72IBNNp.gif)



## UI 작동 화면
| 고객 추가 | 초기화 | 고객 연속 추가 |
| :--------: | :--------: | :--------: |
| ![aaa](https://hackmd.io/_uploads/SJf48X7Va.gif)    | ![bbb](https://hackmd.io/_uploads/BJYOLmX46.gif)    | ![ccc](https://hackmd.io/_uploads/r1xFUQmNa.gif)   |

## 구현 내용
### Step1
- Queue 타입 구현을 위한 Linked-list 구현
    - Enqueue, Dequeue, Clear, Peek, isEmpty 구현
    - Generics 활용
- Queue 구현을 Unit Test를 통해 검증


### Step2
- Step1에서 구현한 Queue를 활용하여 1명의 은행원이 한 종류의 업무를 처리하는 상황 구현
- 업무가 종료되면 수행된 시간을 출력하도록 구현
- 실행 시 콘솔을 통해 처리 상황을 확인할 수 있도록 구현


### Step3
- 은행원의 타입을 예금과 대출로 구분하고 각 타입별 은행원 수를 지정할 수 있도록 구현
- 고객 생성 시 타입을 지정하고 타입에 맞는 은행원에게 배정되어 업무를 동시에 수행하도록 구현
    - GCD 활용
    - semaphore 활용
- 고객이 업무를 수행하는 소요시간을 타입별로 설정


### Step4
- 기존의 구성한 Teller와 BankManager를 이용해 앱의 UI를 code base로 구현
- 고객의 대기열이 생성되면 대기중에 Label로 표시
- 고객의 업무를 시작하면 업무중으로 Label을 변경
- 업무가 끝나면 Label삭제
- 고객의 대기열이 존재해 업무를 진행해야 한다면 타이머가 작동을 하고 모든 업무가 끝나면 타이머를 종료한다.
- 초기화 버튼 클릭시 모든 대기열과 타이머를 초기화 


## Trouble Shooting
### Teller내 doTask 코드 내 비동기 코드를 사용한 부분에서 예금이 정상적으로 group.leave()가 되지 않음
![image](https://hackmd.io/_uploads/H15_6B4Ep.png)
**[원인]**
    - for문으로 tellerCount만큼 DispatchQueue가 생성됨
    - 비동기로 실행되는 부분에 있어 예금 은행원 큐1과 예금 은행원 큐2 간의 queue가 비었는지 체크하는 부분과 dequeue가 실행되는 시점의 차이 등으로 큐가 비어 더이상 실행할 상황이 없음에도 while문 내 들어가있는 상황 발생
    - 현재 코드에서는 데이터가 없으면 guard let data = queue.dequeue() else { return } 을 해줌
    - return 시 group.leave() 문을 타지 못하고 빠져나와 group이 끝나지 않는 상태가 됨

**[해결 방법]**
1. 실행되어야 할 구문 처리 후 return 처리
```swift
guard let data = queue.dequeue() else {
    semaphore.signal()
    group.leave()
    return
}
```

2. 실행되어야 구문 처리 후 break 처리
```swift
guard let data = queue.dequeue() else {
    semaphore.signal()
    break
}
```

3. group을 DispatchQueue.global().async(group: group)으로 변경 semaphore.signal()
```swift
guard let data = queue.dequeue() else {
    semaphore.signal()
    break
}
```

### Scroll 동작 시 타이머가 멈춤

**[원인]**
- 타이머와 스크롤의 동작 모드가 다른 모드이기 때문

**[해결 방법]**
- 타이머의 RunLoop의 모드를 변경해서 해결



### 고객 10명 추가 버튼 연속 클릭 시 업무중 리스트에 3개 이상의 라벨이 생성됨
**[원인]**

- Semaphore value 설정이 doTask 내에 있어 추가 버튼 클릭 시 마다 semaphore가 새롭게 초기화되고 적용됨
```swift
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
        ...
```

**[해결 방법]**
- Semaphore value 설정을 Tellers의 저장 프로퍼티로 선언 후 초기화
```swift
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
        ...
```


## 프로젝트를 통해 배운점 및 느낀점
- Queue와 Linked-list 자료구조를 이해하고 구현할 수 있게 되었다.
- StackView를 활용한 커스텀 뷰를 코드로 구현할 수 있게 되었다.
- 동기와 비동기를 이해하게 되었다.
- 동시성 프로그래밍을 위한 GCD를 이해하고 구현할 수 있게 되었다.
- 동시성 프로그래밍 중 UI 요소 업데이트 시 main Queue에서 동작해야한다는 점을 이해하게 되었다.


## 팀원
| 랄라 | 범 |
| :-: | :-: |
| <a href="https://github.com/rarlala"> <img src="https://avatars.githubusercontent.com/u/48057629?v=4"/></a> | <a href="https://github.com/snowy-summer"><img src="https://avatars.githubusercontent.com/u/118453865?v=4"></a> |
