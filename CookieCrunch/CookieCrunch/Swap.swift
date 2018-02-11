//
//  Swap.swift
//  CookieCrunch
//
//  Created by Nicola Solazzo on 11/02/18.
//  Copyright © 2018 Nicola Solazzo. All rights reserved.
//

import Foundation

struct Swap: CustomStringConvertible {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}
