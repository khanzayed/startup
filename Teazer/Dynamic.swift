//
//  Dynamic.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation

class Dynamic<T> {
    
    typealias Listner = (T?) -> Void
    var listner:Listner?
    
    func bind(listner:@escaping Listner) {
        self.listner = listner
    }
    
    func bindAndFire(listner:@escaping Listner) {
        self.listner = listner
        self.listner?(value)
    }
    
    var value: T? {
        didSet {
            self.listner?(value)
        }
    }
    
    init(v:T?) {
        self.value = v
    }
    
}

