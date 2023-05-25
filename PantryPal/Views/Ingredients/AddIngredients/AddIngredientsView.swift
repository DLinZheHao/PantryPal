//
//  AddIngredientsView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit

class AddIngredientsView: UIView {
    @IBAction private func chooseCalendar() {
        guard let calendarView = UINib(nibName: "Calendar", bundle: nil).instantiate(withOwner: self, options: nil).first as? CalendarView else {
            print("畫面創建失敗")
            return
        }
        self.superview?.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: 150),
            calendarView.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }

}
