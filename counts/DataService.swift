//
//  DataService.swift
//  imIn
//
//  Created by Domenic Conversa on 6/7/17.
//  Copyright © 2017 versaTech. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import KeychainSwift

let DB_BASE = Database.database().reference()

class DataService {
    private var _keyChain = KeychainSwift()
    private var _refDatabase = DB_BASE
    
    var keyChain: KeychainSwift {
        get{
            return _keyChain
        } set {
            _keyChain = newValue
        }
    }
}
