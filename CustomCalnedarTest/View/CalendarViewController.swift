//
//  CalendarViewController.swift
//  CustomCalnedarTest
//
//  Created by 굿소프트_이은재 on 5/22/24.
//

import UIKit
import SnapKit
import Combine

final class CalendarViewController: UIViewController {
    //*******************************************************
    // MARK: - UI
    //*******************************************************
    /// 날짜 라벨
    private let dateLabel: UILabel = .init()
        .with
        .font(.systemFont(ofSize: 16, weight: .bold))
        .build()
    /// 이전 달 버튼
    private let prevMonthBtn: UIButton = .init()
    /// 다음 달 버튼
    private let nextMonthBtn: UIButton = .init()
    /// 상단 가로 스택 뷰
    private lazy var topHStackView: UIStackView = .init(arrangedSubviews: [prevMonthBtn, dateLabel, nextMonthBtn])
        .with
        .axis(.horizontal)
        .spacing(12)
        .build()
    /// 커스텀 캘린더 뷰
    private lazy var calendarView: CustomCalendarView = .init()
        .with
        .isPeriod(true)
        .delegate(self)
        .build()
    /// 세로 스택 뷰
    private lazy var vStackView: UIStackView = .init(arrangedSubviews: [topHStackView, calendarView])
        .with
        .axis(.vertical)
        .alignment(.center)
        .spacing(12)
        .build()
    
    //*******************************************************
    // MARK: - LifeCycle
    //*******************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        addBtnActionHandler()
    }
    
    //*******************************************************
    // MARK: - Helpers
    //*******************************************************
    /**
     * UI 초기 설정
     * - Author: EJLee1209
     */
    private func configUI() {
        view.backgroundColor = .white
        
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY)
        }
        calendarView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        [prevMonthBtn, nextMonthBtn].forEach { btn in
            btn.snp.makeConstraints { make in
                make.size.equalTo(36)
            }
        }
        
        prevMonthBtn.setImage(UIImage(named: "icon_arrow_left"), for: .normal)
        nextMonthBtn.setImage(UIImage(named: "icon_arrow_right"), for: .normal)
    }
    
    /**
     * 버튼 액션 핸들러 등록
     * - Author: EJLee1209
     */
    private func addBtnActionHandler() {
        prevMonthBtn.addTarget(self, action: #selector(prevMonthBtnAction(_:)), for: .touchUpInside)
        nextMonthBtn.addTarget(self, action: #selector(nextMonthBtnAction(_:)), for: .touchUpInside)
    }
}

extension CalendarViewController {
    /**
     * 이전 달 버튼 액션
     * - Author: EJLee1209
     * - Parameters:
     *   - sender : UIButton
     */
    @objc private func prevMonthBtnAction(_ sender: UIButton) {
        calendarView.scrollTo(page: .previous)
    }
    
    /**
     * 다음 달 버튼 액션
     * - Author: EJLee1209
     * - Parameters:
     *   - sender : UIButton
     */
    @objc private func nextMonthBtnAction(_ sender: UIButton) {
        calendarView.scrollTo(page: .next)
    }
}

// MARK: - CustomCalendarViewDelegate
extension CalendarViewController: CustomCalendarViewDelegate {
    func calendarView(_ calendarView: CustomCalendarView, didSelectDate date: Date) {
        print("DEBUG: \(date)")
        
    }
    
    func calendarView(_ calendarView: CustomCalendarView, afterScrollCalendarDate date: Date) {
        dateLabel.text = date.dateToString(dateFormat: "yyyy년 MM월")
    }
}
