// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore

enum ImportType {
    case keystore(string: String, password: String)
    case privateKey(privateKey: String)
    case mnemonic(words: [String], password: String)
    case watch(address: TrustCore.Address)
}
