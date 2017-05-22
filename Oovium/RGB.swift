//
//  RGB.swift
//  Oovium
//
//  Created by Joe Charlier on 4/9/17.
//  Copyright © 2017 Aepryus Software. All rights reserved.
//

import UIKit

struct RGB {
	let r: Float
	let g: Float
	let b: Float
	let a: Float
	let uiColor: UIColor
	
	private init (r: Float, g: Float, b: Float, a: Float, uiColor: UIColor) {
		self.r = r
		self.g = g
		self.b = b
		self.a = a
		self.uiColor = uiColor
	}
	init (r: Float, g: Float, b: Float, a: Float) {
		let uiColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
		self.init(r: r, g: g, b: b, a: a, uiColor: uiColor)
	}
	init (r: Float, g: Float, b: Float) {
		self.init(r: r, g: g, b: b, a: 1)
	}
	init (uiColor: UIColor) {
		let c = uiColor.cgColor.components!
		self.init(r: Float(c[0]), g: Float(c[1]), b: Float(c[2]), a: Float(c[3]), uiColor: uiColor)
	}
	
	static func + (p: RGB, q: RGB) -> RGB {
		return RGB(r: p.r+q.r, g: p.g+q.g, b: p.b+q.b, a: p.a+q.a)
	}
	static func - (p: RGB, q: RGB) -> RGB {
		return RGB(r: p.r-q.r, g: p.g-q.g, b: p.b-q.b, a: p.a-q.a)
	}
	static func * (p: RGB, q: Float) -> RGB {
		return RGB(r: p.r*q, g: p.g*q, b: p.b*q, a: p.a*q)
	}
	
	func blend (rgb: RGB, percent: Float) -> RGB {
		return self + (rgb - self) * percent
	}
	
	var cgColor: CGColor {
		return uiColor.cgColor
	}
	
	
// Static ==========================================================================================
	static var black = RGB(r: 0, g: 0, b: 0, a: 1)
	static var white = RGB(r: 1, g: 1, b: 1, a: 1)
	
	static func tint (color: UIColor, percent: Double) -> UIColor {
		return UIColor.white
	}
	static func tone (color: UIColor, percent: Double) -> UIColor {
		return UIColor.white
	}
	static func shade (color: UIColor, percent: Double) -> UIColor {
		return UIColor.white
	}
}