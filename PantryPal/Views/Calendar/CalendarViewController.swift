//
//  CalendarViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/1.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {
    var historyData: [IngredientsHistoryPresentData] = []
    
    enum Const {
        static let closeCellHeight: CGFloat = 75
        static let openCellHeight: CGFloat = 225
        static let rowsCount = 10
    }
    var cellHeights: [CGFloat] = []
    
    var chineseCalendar: Calendar!
    var calendarClickBlock: ((Bool, Int) -> Void)?
    var currentDate: Date?
    
    private var calendarViewHeightConstraint: NSLayoutConstraint!
    private var calendarBackgroundHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var calendarBackground: UIImageView!
    
    @IBOutlet weak var dataTableView: UITableView! {
        didSet {
            dataTableView.dataSource = self
            dataTableView.delegate = self
        }
    }
    
    @IBOutlet weak var calendarView: FSCalendar! {
        didSet {
            calendarView.delegate = self
            calendarView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarSetUp()
        dataTableView.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        setup()
        ingredientsLog(chooseDay: Date()){ [weak self] dataArray in
            self?.historyData = dataArray
            DispatchQueue.main.async {
                self?.dataTableView.reloadData()
            }
        }
    }
}
// MARK: tableView 控制
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return historyData.count
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DataCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)
        guard let dataCell = cell as? DataCell else { return cell}
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        dataCell.durationsForExpandedState = durations
        dataCell.durationsForCollapsedState = durations
        
        // 放入資料
        dataCell.ingredientsNameLabel.text = historyData[indexPath.row].name
        dataCell.numberLabel.text = "#\(indexPath.row + 1)"
        dataCell.priceLabel.text = "\(Int(historyData[indexPath.row].price))元"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let date = Date(timeIntervalSince1970: historyData[indexPath.row].createdTime)
        dataCell.createdTimeLabel.text = "創建於：\(dateFormatter.string(from: date))"
        
        dataCell.storeStatusLabel.text = "\(StoreStatus.getStatus(input: historyData[indexPath.row].storeStatus))"
        dataCell.statusLabel.text = "狀態：\(ActionStatus.getStatus(input: historyData[indexPath.row].action))"
        dataCell.barcodeLabel.text = historyData[indexPath.row].barcode
        dataCell.descriptionTextView.text = historyData[indexPath.row].description
        
        UIImage.downloadImage(from: URL(string: historyData[indexPath.row].url)!) { image in
            DispatchQueue.main.async {
                dataCell.ingredientsImage.image = image
            }
        }
        return dataCell
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath)
        guard let dataCell = cell as? DataCell else { return }
        if dataCell.isAnimating() {
            return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            dataCell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            dataCell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if dataCell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }
    // MARK: Helpers
    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        dataTableView.estimatedRowHeight = Const.closeCellHeight
        dataTableView.rowHeight = UITableView.automaticDimension
        // dataTableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        if #available(iOS 10.0, *) {
            dataTableView.refreshControl = UIRefreshControl()
            dataTableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    // MARK: Actions
    @objc func refreshHandler() {
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.dataTableView.refreshControl?.endRefreshing()
            }
            if self!.currentDate != nil {
                ingredientsLog(chooseDay: self!.currentDate!) { [weak self] dataArray in
                    self?.historyData = dataArray
                    DispatchQueue.main.async {
                        self?.dataTableView.reloadData()
                    }
                }
                
            }
        })
    }
}
// MARK: 日曆控制及相關設定
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendarSetUp() {
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
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date
        ingredientsLog(chooseDay: date) { [weak self] dataArray in
            self?.historyData = dataArray
            DispatchQueue.main.async {
                self?.dataTableView.reloadData()
            }
        }
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    // MARK: 手勢切換日曆
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
