//
//  DateFormatter+Extensions.swift
//  bereal-clone
//
//  Created by Benjamin Woosley on 3/24/23.
//

import Foundation

extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
