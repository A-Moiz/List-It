//
//  VerificationStatus.swift
//  List It
//
//  Created by Abdul Moiz on 03/01/2026.
//

import Foundation

enum VerificationStatus: Equatable {
    case pending
    case verified
    case error(String)
}
