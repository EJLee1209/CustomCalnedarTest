//
//  Extensions.swift
//  CustomCalnedarTest
//
//  Created by 굿소프트_이은재 on 5/23/24.
//

import UIKit

extension Date {
    /**
     * Date 객체의 Component 반환
     * - Author: EJLee1209
     * - Parameters:
     *   - component : Calendar.Component
     * - Returns: Int
     */
    func dateComponent(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
    
    /**
     * Date -> String
     * - Author: EJLee1209
     * - Parameters:
     *   - dateFormat : 날짜 형식
     */
    func dateToString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    /**
     * 상대적인 날짜를 생성
     * - Author: EJLee1209
     * - Parameters:
     *   - byAdding : Calendar.Component
     *   - value : Int
     * - Returns: Date?
     */
    func relativeDate(byAdding: Calendar.Component, value: Int) -> Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: byAdding, value: value, to: self)
    }
    
    /// 현재 달의 첫번째 날짜
    var firstDateOfMonth: Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.day = 1
        return calendar.date(from: components)
    }
    
    /// 달의 마지막 날짜
    var lastDateOfMonth: Date? {
        let nextMonthFirstDate = self.relativeDate(byAdding: .month, value: 1)?.firstDateOfMonth
        return nextMonthFirstDate?.relativeDate(byAdding: .day, value: -1)
    }
    
    /// 달의 첫번째 요일
    var firstWeekDay: Int? {
        return firstDateOfMonth?.dateComponent(.weekday)
    }
    
    /// 달의 모든 날짜
    var allDaysOfMonth: [Date] {
        guard let firstDateOfMonth = firstDateOfMonth,
              let lastDateOfMonth = lastDateOfMonth,
              let firstWeekDay = firstWeekDay
        else {
            return []
        }
        
        var allDays = [Date]()
        var date = firstDateOfMonth.relativeDate(byAdding: .day, value: -firstWeekDay + 1)!
        while date <= lastDateOfMonth {
            allDays.append(date)
            date = date.relativeDate(byAdding: .day, value: 1)!
        }
        return allDays
    }
}

extension UIView {
    /**
     * 모서리 둥글게
     * - Author: EJLee1209
     * - Parameters:
     *   - radius : CGFloat
     */
    func roundCorner(radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
    }
    
    /**
     * 특정 모서리만 둥글게
     * - Author: EJLee1209
     * - Parameters:
     *   - radius : CGFloat
     *   - maskedCorners : CACornerMask
     */
    func roundCorners(radius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
}
