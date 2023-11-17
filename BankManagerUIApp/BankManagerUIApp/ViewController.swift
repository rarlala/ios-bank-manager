//
//  BankManagerUIApp - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom academy. All rights reserved.
// 


import UIKit

final class ViewController: UIViewController {
    
    private var bankManager = BankManager(depositTellerCount: 2, loanTellerCount: 1)
    
    private var timer: Timer = Timer()
    private var time: Double = 0
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var addCustomerButton: UIButton = {
        let button = UIButton()
        button.setTitle("고객 10명 추가", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(addCustomer), for: .touchUpInside)
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var timerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "업무 시간 - 00:00:00"
        label.textAlignment = .center
        label.font = .monospacedSystemFont(ofSize: 24, weight: .regular)
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var readyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "대기중"
        label.textAlignment = .center
        label.backgroundColor = .systemGreen
        label.textColor = .white
        label.font = .systemFont(ofSize: 40)
        return label
    }()
    
    private lazy var runningTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "업무중"
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.textColor = .white
        label.font = .systemFont(ofSize: 40)
        return label
    }()
    
    private lazy var listStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var readyListView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var runningListView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var readyListScrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var runningListScrollView: UIScrollView = {
        let view = UIScrollView()
        view.bounces = false
        return view
    }()
    
    private lazy var readyListStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        return view
    }()
    
    private lazy var runningListStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        setupAutoLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(addDepositLabel), name: NSNotification.Name("AddDepositLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addLoanLabel), name: NSNotification.Name("AddLoanLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeReadyListLabel), name: NSNotification.Name("RemoveReadyLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeRunningLabel), name: NSNotification.Name("RemoveRunningLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: NSNotification.Name("StopTimer"), object: nil)
    }
    
    func configure() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(buttonStackView)
        mainStackView.addArrangedSubview(timerTitleLabel)
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(listStackView)
        
        buttonStackView.addArrangedSubview(addCustomerButton)
        buttonStackView.addArrangedSubview(resetButton)
        
        titleStackView.addArrangedSubview(readyTitleLabel)
        titleStackView.addArrangedSubview(runningTitleLabel)
        
        // listStackView -> readyListView / runningListView
        // readyListView -> readyListScrollView -> readyListStackView
        listStackView.addArrangedSubview(readyListView)
        listStackView.addArrangedSubview(runningListView)
        
        readyListView.addSubview(readyListScrollView)
        runningListView.addSubview(runningListScrollView)
        
        readyListScrollView.addSubview(readyListStackView)
        runningListScrollView.addSubview(runningListStackView)
    }
    
    func setupAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        
        readyListScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        readyListScrollView.topAnchor.constraint(equalTo: readyListView.topAnchor).isActive = true
        readyListScrollView.bottomAnchor.constraint(equalTo: readyListView.bottomAnchor).isActive = true
        readyListScrollView.leadingAnchor.constraint(equalTo: readyListView.leadingAnchor).isActive = true
        readyListScrollView.trailingAnchor.constraint(equalTo: readyListView.trailingAnchor).isActive = true
        
        runningListScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        runningListScrollView.topAnchor.constraint(equalTo: runningListView.topAnchor).isActive = true
        runningListScrollView.bottomAnchor.constraint(equalTo: runningListView.bottomAnchor).isActive = true
        runningListScrollView.leadingAnchor.constraint(equalTo: runningListView.leadingAnchor).isActive = true
        runningListScrollView.trailingAnchor.constraint(equalTo: runningListView.trailingAnchor).isActive = true
        
        readyListStackView.translatesAutoresizingMaskIntoConstraints = false
        
        readyListStackView.topAnchor.constraint(equalTo: readyListScrollView.topAnchor).isActive = true
        readyListStackView.bottomAnchor.constraint(equalTo: readyListScrollView.bottomAnchor).isActive = true
        readyListStackView.leadingAnchor.constraint(equalTo: readyListScrollView.leadingAnchor).isActive = true
        readyListStackView.trailingAnchor.constraint(equalTo: readyListScrollView.trailingAnchor).isActive = true
        readyListStackView.widthAnchor.constraint(equalTo: readyListScrollView.widthAnchor).isActive = true
        
        runningListStackView.translatesAutoresizingMaskIntoConstraints = false
        
        runningListStackView.topAnchor.constraint(equalTo: runningListScrollView.topAnchor).isActive = true
        runningListStackView.bottomAnchor.constraint(equalTo: runningListScrollView.bottomAnchor).isActive = true
        runningListStackView.leadingAnchor.constraint(equalTo: runningListScrollView.leadingAnchor).isActive = true
        runningListStackView.trailingAnchor.constraint(equalTo: runningListScrollView.trailingAnchor).isActive = true
        runningListStackView.widthAnchor.constraint(equalTo: runningListScrollView.widthAnchor).isActive = true
    }
    
    @objc func addCustomer() {
        DispatchQueue.global().async { [self] in
            bankManager.createCustomerQueue(customerCount: 10)
            bankManager.totalCustomer += 10
            startTimer()
            bankManager.startTask()
        }
    }
    
    func startTimer() {
        DispatchQueue.main.async { [self] in
            if !timer.isValid {
                timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(setTimerLabel), userInfo: nil, repeats: true)
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    @objc func stopTimer() {
        timer.invalidate()
    }
    
    func resetTimer() {
        stopTimer()
        time = 0
        bankManager.totalCustomer = 0
        timerTitleLabel.text = "00 : 00 : 000"
    }
    
    @objc func setTimerLabel() {
        let minute: String = String(format: "%02d", Int(time / 60))
        let second: String = String(format: "%02d", Int(time) % 60)
        let millisecond = String(format: "%03d", Int(time * 1000) % 1000)
        
        time += 0.001
        timerTitleLabel.text = "\(minute) : \(second) : \(millisecond)"
    }
    
    private func makeLabel(type: TypeOfWork, number: Any) {
        DispatchQueue.main.async { [self] in
            let label = UILabel()
            label.text = "\(number) - \(type.name)"
            label.textAlignment = .center
            label.textColor = type == TypeOfWork.Deposit ? .orange : .black
            readyListStackView.addArrangedSubview(label)
        }
    }
    
    @objc func addDepositLabel(_ notification: Notification) {
        guard let number = notification.object else { return }
        makeLabel(type: .Deposit, number: number)
    }
    
    @objc func addLoanLabel(_ notification: Notification) {
        guard let number = notification.object else { return }
        makeLabel(type: .Loan, number: number)
    }
    
    @objc func removeReadyListLabel(_ notification: Notification) {
        guard let data = notification.object else { return }
        
        DispatchQueue.main.async { [self] in
            let readySubviews = readyListStackView.arrangedSubviews
            var resultLabel: UILabel?
            
            readySubviews.forEach { label in
                guard let label = label as? UILabel, let text = label.text else { return }
                if text == data as? String {
                    resultLabel = label
                }
            }
            
            guard let label = resultLabel else { return }
            label.removeFromSuperview()
            runningListStackView.addArrangedSubview(label)
        }
    }
    
    @objc func removeRunningLabel(_ notification: Notification) {
        guard let data = notification.object else { return }
        
        DispatchQueue.main.async { [self] in
            let runningSubViews = runningListStackView.arrangedSubviews
            var resultLabel: UILabel?
            
            runningSubViews.forEach { label in
                guard let label = label as? UILabel, let text = label.text else { return }
                if text == data as? String {
                    resultLabel = label
                }
            }
            
            guard let label = resultLabel else { return }
            label.removeFromSuperview()
            
            if runningListStackView.arrangedSubviews.isEmpty && readyListStackView.arrangedSubviews.isEmpty {
                timer.invalidate()
            }
        }
    }
    
    @objc func resetButtonTapped() {
        print("초기화 누름")
        DispatchQueue.main.async { [self] in
            resetTimer()
        }
        
        bankManager.depositCustomerQueue.clear()
        bankManager.loanCustomerQueue.clear()
        let _ = readyListStackView.arrangedSubviews.map { $0.removeFromSuperview() }
    }
    
}


#if canImport(SwiftUI)
import SwiftUI

struct Preview<View: UIView>: UIViewRepresentable {
    let view: View
    
    init(_ interfaceBuilder: @escaping () -> View) {
        view = interfaceBuilder()
    }
    
    func makeUIView(context: Context) -> some UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

struct Previewer: PreviewProvider {
    static var previews: some View {
        Preview {
            let viewController = ViewController()
            return viewController.view
        }
    }
}
#endif
