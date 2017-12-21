//
//  RCCountdownTimerView.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
class RCCountdownTimerView: UIView {
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var hourLabel: UILabel!
    @IBOutlet private weak var minLabel: UILabel!
    @IBOutlet private weak var secLabel: UILabel!
    var deliveryDate: Date?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateView()
        self.startTimer()
    }
    func startTimer() {
        Observable<Int>.interval(RxTimeInterval(1.0), scheduler: MainScheduler.instance).subscribe(onNext: { (_) in
            self.updateView()
        })
    }
    func updateView() {
        guard let deliveryDate = self.deliveryDate else { return }
        guard deliveryDate.timeIntervalSinceNow >= 0 else {return}
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.hour,.minute,.second], from: now, to: deliveryDate)
        if let day = components.day, let hour = components.hour, let min = components.minute, let sec = components.second {
            self.dayLabel.text = "\(day)"
            self.hourLabel.text = "\(hour)"
            self.minLabel.text = "\(min)"
            self.secLabel.text = "\(sec)"
        }
    }
}
