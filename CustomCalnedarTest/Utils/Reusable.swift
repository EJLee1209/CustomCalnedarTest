//
//  Reusable.swift
//  CustomCalnedarTest
//
//  Created by 굿소프트_이은재 on 5/22/24.
//

protocol Reusable {}
extension Reusable {
    static var identifier: String {
        return String(describing: self)
    }
}
