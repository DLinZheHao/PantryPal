//
//  CalendarViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/1.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {
    var chineseCalendar: Calendar!
    var calendarClickBlock: ((Bool, Int) -> Void)?

    private var calendarViewHeightConstraint: NSLayoutConstraint!
    private var calendarBackgroundHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var calendarBackground: UIImageView!
    
    @IBOutlet weak var calendarView: FSCalendar! {
        didSet {
            calendarView.delegate = self
            calendarView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chineseCalendar = Calendar(identifier: .chinese)
        calendarView.pagingEnabled = true
        calendarView.scrollEnabled = true
        
        let locale = Locale(identifier: "zh_CN")
        calendarView.locale = locale
        calendarView.appearance.caseOptions = .weekdayUsesSingleUpperCase
        calendarView.placeholderType = .none
        calendarView.appearance.titleDefaultColor = .white
        calendarView.appearance.titleTodayColor = .white
        calendarView.appearance.todayColor = .lightGray
        calendarView.appearance.weekdayTextColor = .white
        calendarView.appearance.titleWeekendColor = .lightGray
        calendarView.appearance.subtitleWeekendColor = .yellow

        calendarView.appearance.headerTitleColor = .white
        calendarView.appearance.headerDateFormat = "yyyy年MM月"
        
        calendarView.appearance.selectionColor = .darkGray
        calendarView.appearance.subtitleSelectionColor = .yellow
        calendarView.appearance.borderRadius = 0.4

        calendarView.scrollDirection = .horizontal
        calendarView.scope = .month
        
        // 添加下滑手勢識別器
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeDownGesture.direction = .down
        swipeDownGesture.cancelsTouchesInView = false
        calendarView.addGestureRecognizer(swipeDownGesture)

        // 添加上滑手勢識別器
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeUpGesture.direction = .up
        swipeUpGesture.cancelsTouchesInView = false
        calendarView.addGestureRecognizer(swipeUpGesture)
        calendarView.isUserInteractionEnabled = true
        
        // 設置初始的高度約束
        calendarViewHeightConstraint = calendarView.heightAnchor.constraint(equalToConstant: 335)
        calendarBackgroundHeightConstraint = calendarBackground.heightAnchor.constraint(equalToConstant: 335)
        
        NSLayoutConstraint.activate([
            calendarViewHeightConstraint,
            calendarBackgroundHeightConstraint
        ])
    }
    
}
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        print(dateFormatter.string(from: date))

        let result = compareOneDay(date, withAnotherDay: Date())
        let timestamp = getNowTimestampWithDate(date)
        
        if result == -1 {
            calendarClickBlock?(false, timestamp)
        } else {
            calendarClickBlock?(true, timestamp)
        }
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }

    func compareOneDay(_ currentDay: Date, withAnotherDay baseDay: Date) -> Int {
        let calendar = Calendar.current
        let result = calendar.compare(currentDay, to: baseDay, toGranularity: .day)
        switch result {
        case .orderedDescending:
            return 1
        case .orderedAscending:
            return -1
        default:
            return 0
        }
    }
    
    func getNowTimestampWithDate(_ date: Date) -> Int {
        return Int(date.timeIntervalSince1970)
    }
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        print("觸發 ")
        if gesture.direction == .down {
            // 下滑手勢，改變scope為.month
            calendarViewHeightConstraint.constant = 335
            calendarBackgroundHeightConstraint.constant = 335
            UIView.animate(withDuration: 0.3) { [self] in
                calendarView.scope = .month
                self.view.layoutIfNeeded()
            }
        } else if gesture.direction == .up {
            // 上滑手勢，改變scope為.week
            calendarViewHeightConstraint.constant = 123
            calendarBackgroundHeightConstraint.constant = 123
            UIView.animate(withDuration: 0.3) { [self] in
                calendarView.scope = .week
                self.view.layoutIfNeeded()
            }
            
        }
        
    }
}
