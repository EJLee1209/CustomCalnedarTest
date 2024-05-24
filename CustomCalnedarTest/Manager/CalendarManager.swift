//
//  CalendarManager.swift
//  CustomCalnedarTest
//
//  Created by 굿소프트_이은재 on 5/23/24.
//

import Foundation

final class CalendarManager {
    // 달력 페이지 정보를 담는 구조체
    struct CalendarPageInfo {
        /// 달력 날짜
        var calendarDate: Date {
            didSet {
                // 달력 날짜가 변경되면 날짜 리스트도 변경되도록
                calendarDateList = calendarDate.allDaysOfMonth
            }
        }
        /// 달력 날짜 리스트
        var calendarDateList: [Date]
    }
    /// 현재 달력 페이지 정보
    private(set) var currentPageCalendarInfo: CalendarPageInfo
    /// 이전 달력 페이지 정보
    private(set) var previousPageCalendarInfo: CalendarPageInfo
    /// 다음 달력 페이지 정보
    private(set) var nextPageCalendarInfo: CalendarPageInfo
    /// 현재 날짜
    private var currentDate: Date
    /// 선택한 시작 날짜
    private(set) var selectedStartDate: Date?
    /// 선택한 종료 날짜
    private(set) var selectedEndDate: Date?
    /// 기간 선택 가능 여부(false면 selectedStartDate만 사용)
    private var isPeriod: Bool
    
    init(isPeriod: Bool) {
        currentDate = .init()
        let currentCalendarDate = currentDate.firstDateOfMonth!
        currentPageCalendarInfo = .init(calendarDate: currentCalendarDate, calendarDateList: currentCalendarDate.allDaysOfMonth)
        let previousCalendarDate = currentCalendarDate.relativeDate(byAdding: .month, value: -1)!
        previousPageCalendarInfo = .init(calendarDate: previousCalendarDate, calendarDateList: previousCalendarDate.allDaysOfMonth)
        let nextCalendarDate = currentCalendarDate.relativeDate(byAdding: .month, value: 1)!
        nextPageCalendarInfo = .init(calendarDate: nextCalendarDate, calendarDateList: nextCalendarDate.allDaysOfMonth)
        self.isPeriod = isPeriod
    }
    
    // 캘린더 스크롤 방향 (좌/우)
    enum ScrollDirection {
        case left, right
    }
    /**
     * 캘린더 좌우 스크롤시 호출
     * - Author: EJLee1209
     * - Parameters:
     *   - direction : ScrollDirection
     */
    func didScroll(direction: ScrollDirection) {
        let currentCalendarDate = currentPageCalendarInfo.calendarDate
        let previousCalendarDate = previousPageCalendarInfo.calendarDate
        let nextCalendarDate = nextPageCalendarInfo.calendarDate
        
        let value: Int
        switch direction {
        case .left:
            value = -1
        case .right:
            value = 1
        }
        
        currentPageCalendarInfo.calendarDate = currentCalendarDate.relativeDate(byAdding: .month, value: value)!
        previousPageCalendarInfo.calendarDate = previousCalendarDate.relativeDate(byAdding: .month, value: value)!
        nextPageCalendarInfo.calendarDate = nextCalendarDate.relativeDate(byAdding: .month, value: value)!
    }
    
    /**
     * 날짜 선택
     * - Author: EJLee1209
     * - Parameters:
     *   - date : Date
     */
    func selectDate(_ date: Date) {
        guard isPeriod else {
            selectedStartDate = date
            return
        }
        guard let selectedStartDate = selectedStartDate else {
            self.selectedStartDate = date
            return
        }
        if selectedEndDate != nil {
            self.selectedStartDate = date
            self.selectedEndDate = nil
            return
        }
        if date >= selectedStartDate {
            selectedEndDate = date
        } else {
            self.selectedStartDate = date
            selectedEndDate = nil
        }
    }
    
    enum DateSelectionStatus {
        /// 선택 상태가 아님
        case none
        /// 날짜 하나 선택
        case selectOne
        /// 시작 날짜
        case start
        /// 종료 날짜
        case end
        /// 시작과 종료 날짜 중간 사이
        case middle
    }
    /**
     * 날짜 선택 상태를 확인
     * - Author: EJLee1209
     * - Parameters:
     *   - date : Date
     * - Returns: DateSelectionStatus
     */
    func dateSelectionStatus(_ date: Date) -> DateSelectionStatus {
        guard let startDate = selectedStartDate else {
            return .none
        }
        guard let endDate = selectedEndDate else {
            return date == startDate ? .selectOne : .none
        }
        if date == startDate {
            return startDate == endDate ? .selectOne : .start
        } else if date == endDate {
            return startDate == endDate ? .selectOne : .end
        } else if date > startDate && date < endDate {
            return .middle
        }
        return .none
    }
    
}
