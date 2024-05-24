//
//  CalendarItemCell.swift
//  CustomCalnedarTest
//
//  Created by 굿소프트_이은재 on 5/22/24.
//

import UIKit

final class CalendarItemCell: UICollectionViewCell {
    
    private let dateLabel: UILabel = .init()
        .with
        .textAlignment(.center)
        .numberOfLines(1)
        .text("0")
        .font(.systemFont(ofSize: 14, weight: .semibold))
        .build()
    
    private let statusView: UIView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dateLabel.textColor = .black
        statusView.backgroundColor = .clear
    }
    
    private func configUI() {
        contentView.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(statusView.snp.width).multipliedBy(0.76)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configData(
        _ date: Date,
        isThisMonth: Bool,
        status: CalendarManager.DateSelectionStatus,
        withAnimate: Bool
    ) {
        dateLabel.text = date.dateToString(dateFormat: "d")
        
        if !isThisMonth {
            dateLabel.textColor = .systemGray3
        }
        switch status {
        case .none:
            break
        case .selectOne:
            updateStatusViewUI(
                maskedCorners: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner],
                backgroundColor: .black,
                textColor: .white,
                withAnimate: withAnimate
            )
        case .start:
            updateStatusViewUI(
                maskedCorners: [.layerMinXMinYCorner, .layerMinXMaxYCorner],
                backgroundColor: .black,
                textColor: .white,
                withAnimate: withAnimate
            )
        case .end:
            updateStatusViewUI(
                maskedCorners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner],
                backgroundColor: .black,
                textColor: .white,
                withAnimate: withAnimate
            )
        case .middle:
            updateStatusViewUI(
                maskedCorners: [],
                backgroundColor: .black,
                textColor: .white,
                withAnimate: withAnimate
            )
        }
    }
    
    private func updateStatusViewUI(
        maskedCorners: CACornerMask,
        backgroundColor: UIColor,
        textColor: UIColor,
        withAnimate animate: Bool
    ) {
        statusView.roundCorners(radius: statusView.bounds.height / 2, maskedCorners: maskedCorners)
        statusView.backgroundColor = backgroundColor
        dateLabel.textColor = textColor
        if animate {
            UIView.animate(withDuration: 0.1) {
                self.statusView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.statusView.transform = .identity
                })
            }
        }
    }
}

extension CalendarItemCell: Reusable {}
