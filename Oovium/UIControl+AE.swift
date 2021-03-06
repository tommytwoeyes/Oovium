//
//  UIButton+AE.swift
//  Oovium
//
//  Created by Joe Charlier on 1/2/17.
//  Copyright © 2017 Aepryus Software. All rights reserved.
//

import UIKit

fileprivate class ClosureSleeve {
	let closure:()->()
	
	init (_ closure: @escaping()->()) {
		self.closure = closure
	}
	
	@objc func invoke() {
		closure()
	}
}

extension UIControl {
	public func add (for controlEvents: UIControlEvents, _ closure: @escaping()->()) {
		let sleeve = ClosureSleeve(closure)
		addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
		objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
	}
}
