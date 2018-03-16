//
//  Listen.swift
//  BLU
//
//  Created by Joe Bakalor on 3/8/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation

class Listen<T>{
    
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T{
        didSet{
            listener?(value)
        }
    }
    
    init(_ value: T){
        self.value = value
    }
    
    func bind(listener: Listener?){
        self.listener = listener
        listener?(value)
    }
}

