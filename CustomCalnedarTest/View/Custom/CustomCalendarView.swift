//
//  CustomCalendarView.swift
//  CustomCalnedarTest
//
//  Created by 굿소프트_이은재 on 5/22/24.
//

import UIKit

protocol CustomCalendarViewDelegate: AnyObject {
    /**
     * 달력의 날짜 선택시 호출
     * - Author: EJLee1209
     * - Parameters:
     *   - calendarView : CustomCalendarView
     *   - didSelectDate : Date
     */
    func calendarView(_ calendarView: CustomCalendarView, didSelectDate date: Date)
    
    /**
     * 달력이 좌/우 스크롤 됐을 때 호출
     * - Author: EJLee1209
     * - Parameters:
     *   - calendarView : CustomCalendarView
     *   - afterScrollCalendarDate : 스크롤 된 후 달력 날짜
     */
    func calendarView(_ calendarView: CustomCalendarView, afterScrollCalendarDate date: Date)
}

final class CustomCalendarView: UIView {
    //*******************************************************
    // MARK: - UI
    //*******************************************************
    /// 가로 페이지 스크롤 뷰
    private lazy var horizontalPageScrollView: UIScrollView = .init()
        .with
        .isPagingEnabled(true)
        .delegate(self)
        .showsHorizontalScrollIndicator(false)
        .showsVerticalScrollIndicator(false)
        .build()
    /// 캘린더 컬렉션 뷰 배열
    private var calendarCollectionViewArray: [UICollectionView] = .init()
    /// 캘린더 페이지 (이전, 현재, 다음)
    enum CalendarPage: String, CaseIterable { case previous, current, next }
    /// 컬렉션 뷰 플로우 레이아웃 딕셔너리
    private var flowLayoutDict: [CalendarPage: UICollectionViewFlowLayout] = .init()
    
    //*******************************************************
    // MARK: - Properties
    //*******************************************************
    /// 레이아웃 여부
    private var isLayout: Bool = false
    /// 셀 애니메이션
    private var isAnimate: Bool = false
    /// 기간 선택 여부
    var isPeriod: Bool = true
    /// 한글 여부
    private var isKorean: Bool
    /// 캘린더 매니저
    private lazy var calendarManager: CalendarManager = .init(isPeriod: self.isPeriod)
    /// delegate
    weak var delegate: CustomCalendarViewDelegate? {
        didSet {
            delegate?.calendarView(self, afterScrollCalendarDate: calendarManager.currentPageCalendarInfo.calendarDate)
        }
    }
    /// 요일
    enum WeekDay: CaseIterable {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        
        var kr: String {
            switch self {
            case .sunday:
                "일"
            case .monday:
                "월"
            case .tuesday:
                "화"
            case .wednesday:
                "수"
            case .thursday:
                "목"
            case .friday:
                "금"
            case .saturday:
                "토"
            }
        }
        var en: String {
            switch self {
            case .sunday:
                "S"
            case .monday:
                "M"
            case .tuesday:
                "T"
            case .wednesday:
                "W"
            case .thursday:
                "T"
            case .friday:
                "F"
            case .saturday:
                "S"
            }
        }
    }
    
    //*******************************************************
    // MARK: - init
    //*******************************************************
    init(isKorean: Bool = false) {
        self.isKorean = isKorean
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.resizingCellItems()
        
        guard !isLayout else { return }
        isLayout.toggle()
        
        horizontalPageScrollView.setContentOffset(.init(x: self.bounds.width, y: 0), animated: false)
    }
    
    //*******************************************************
    // MARK: - Helpers
    //*******************************************************
    /**
     * UI 초기 설정
     * - Author: EJLee1209
     */
    private func configUI() {
        let weekDayHeaderView = UIStackView()
            .with
            .axis(.horizontal)
            .spacing(0)
            .distribution(.fillEqually)
            .build()
        WeekDay.allCases.map { isKorean ? $0.kr : $0.en }.forEach { dayOfWeek in
            let label = UILabel()
                .with
                .text(dayOfWeek)
                .font(.systemFont(ofSize: 13, weight: .bold))
                .textAlignment(.center)
                .build()
            weekDayHeaderView.addArrangedSubview(label)
        }
    
        addSubview(weekDayHeaderView)
        weekDayHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        let divider = UIView()
            .with
            .backgroundColor(.systemGray6)
            .build()
        
        addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(weekDayHeaderView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        addSubview(horizontalPageScrollView)
        horizontalPageScrollView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let contentView = UIView()
        horizontalPageScrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(3)
        }
        
        CalendarPage.allCases.forEach { page in
            let layout = UICollectionViewFlowLayout()
            flowLayoutDict[page] = layout
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.isScrollEnabled = false
            collectionView.register(CalendarItemCell.self, forCellWithReuseIdentifier: CalendarItemCell.identifier)
            collectionView.accessibilityIdentifier = page.rawValue
            calendarCollectionViewArray.append(collectionView)
        }
        
        let hStackView = UIStackView(arrangedSubviews: calendarCollectionViewArray)
            .with
            .axis(.horizontal)
            .spacing(0)
            .distribution(.fillEqually)
            .build()
        
        contentView.addSubview(hStackView)
        hStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /**
     * 스크롤 뷰 스크롤
     * - Author: EJLee1209
     * - Parameters:
     *   - page : CalendarPage
     *   - withAnimate : Bool
     */
    func scrollTo(page: CalendarPage, withAnimate animated: Bool = false) {
        guard let collectionView = calendarCollectionViewArray.first(where: { $0.accessibilityIdentifier == page.rawValue }) else { return }
        horizontalPageScrollView.setContentOffset(.init(x: collectionView.frame.minX, y: 0), animated: animated)
    }
    
    /**
     * 컬렉션 뷰 셀 리사이징
     * - Author: EJLee1209
     */
    private func resizingCellItems() {
        calendarCollectionViewArray.forEach { cv in
            let identifier = cv.accessibilityIdentifier
            if let calendarPage = CalendarPage(rawValue: identifier ?? "") {
                var dateCount: Double?
                if calendarPage == .current {
                    dateCount = Double(calendarManager.currentPageCalendarInfo.calendarDateList.count)
                } else if calendarPage == .previous {
                    dateCount = Double(calendarManager.previousPageCalendarInfo.calendarDateList.count)
                } else if calendarPage == .next {
                    dateCount = Double(calendarManager.nextPageCalendarInfo.calendarDateList.count)
                }
                if let dateCount = dateCount, cv.bounds != .zero {
                    let numberOfRow = ceil(dateCount / 7)
                    let inset = cv.bounds.width.truncatingRemainder(dividingBy: 7)
                    let itemWidth = (cv.bounds.width - inset) / 7
                    let itemHeight = cv.bounds.height / numberOfRow
                    flowLayoutDict[calendarPage]?.itemSize = .init(width: itemWidth, height: itemHeight)
                    flowLayoutDict[calendarPage]?.sectionInset = .init(top: 0, left: inset / 2, bottom: 0, right: inset / 2)
                }
            }
            isAnimate = false
            cv.reloadData()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension CustomCalendarView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        
        if contentOffsetX >= bounds.width * 2 || contentOffsetX <= 0 {
            
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
                calendarManager.didScroll(direction: .left)
            } else {
                calendarManager.didScroll(direction: .right)
            }
            resizingCellItems()
            scrollTo(page: .current)
            delegate?.calendarView(self, afterScrollCalendarDate: calendarManager.currentPageCalendarInfo.calendarDate)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CustomCalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let identifier = collectionView.accessibilityIdentifier {
            let calendarPage = CalendarPage(rawValue: identifier)
            switch calendarPage {
            case .previous:
                return calendarManager.previousPageCalendarInfo.calendarDateList.count
            case .current:
                return calendarManager.currentPageCalendarInfo.calendarDateList.count
            case .next:
                return calendarManager.nextPageCalendarInfo.calendarDateList.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarItemCell.identifier, for: indexPath)
        if let itemCell = cell as? CalendarItemCell {
            if let identifier = collectionView.accessibilityIdentifier {
                let calendarPage = CalendarPage(rawValue: identifier)
                var calendarPageInfo: CalendarManager.CalendarPageInfo?
                switch calendarPage {
                case .previous:
                    calendarPageInfo = calendarManager.previousPageCalendarInfo
                case .current:
                    calendarPageInfo = calendarManager.currentPageCalendarInfo
                case .next:
                    calendarPageInfo = calendarManager.nextPageCalendarInfo
                default:
                    break
                }
                if let calendarPageInfo = calendarPageInfo {
                    let dataSource = calendarPageInfo.calendarDateList
                    let date = dataSource[indexPath.row]
                    let isThisMonth = date.dateComponent(.month) == calendarPageInfo.calendarDate.dateComponent(.month)
                    itemCell.configData(
                        date,
                        isThisMonth: isThisMonth,
                        status: calendarManager.dateSelectionStatus(date),
                        withAnimate: isAnimate
                    )
                }
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CustomCalendarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let idendifier = collectionView.accessibilityIdentifier else { return }
        let calendarPage = CalendarPage(rawValue: idendifier)
        var date: Date?
        if calendarPage == .current {
            date = calendarManager.currentPageCalendarInfo.calendarDateList[indexPath.row]
        } else if calendarPage == .next {
            date = calendarManager.nextPageCalendarInfo.calendarDateList[indexPath.row]
        } else if calendarPage == .previous {
            date = calendarManager.previousPageCalendarInfo.calendarDateList[indexPath.row]
        }
        guard let date else { return }
        delegate?.calendarView(self, didSelectDate: date)
        calendarManager.selectDate(date)
        
        isAnimate = true
        calendarCollectionViewArray.forEach { cv in
            cv.reloadData()
        }
    }
}
