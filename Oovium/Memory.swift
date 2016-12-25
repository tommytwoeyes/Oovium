//
//  Memory.swift
//  Oovium
//
//  Created by Joe Charlier on 12/11/16.
//  Copyright © 2016 Aepryus Software. All rights reserved.
//

import Foundation

public class Memory: NSObject {
	var index = [String:Int]()
	var slots = [Slot]()
	
	public init (_ names: [String]) {
		super.init()
		for name in names {
			append(name:name)
		}
	}
	
	public subscript (i: Int) -> Obj? {
		get {
			return slots[i].value
		}
	}
	public subscript (name: String) -> Obj? {
		get {
			if let i = index[name] {
				return slots[i].value
			} else {
				return nil
			}
		}
	}
	
	public func mimic (_ i: Int, obj: Obj) {
		let slot = slots[i]
		slot.value.mimic(obj)
		slot.loaded = true
	}
	
	public func fix (_ i: Int, obj:Obj) {
		let slot = slots[i]
		slot.value = obj
		slot.fixed = true
	}
	
	func append (slot: Slot) {
		index[slot.name] = slots.count
		slots.append(slot)
	}
	func append (name: String) {
		append(slot:Slot(name))
	}
	
	func index (for name: String) -> Int {
		return index[name]!;
	}
	
	public func isLoaded (_ i: Int) -> Bool {
		return slots[i].loaded
	}

	public func clear () {
		for slot in slots {
			slot.clear()
		}
	}
	
	public func display () {
		print("[ Memory ================= ]")
		var i = 0
		for slot in slots  {
			let index = String(format: "%2d", i)
			let loaded = slot.loaded ? "O" : " "
			let set = slot.fixed ? "O" : " "
			let name = slot.name.padding(toLength: 12, withPad: " ", startingAt: 0)
			let value = slot.loaded ? "\(slot.value)" : "-"
			print("  [\(index)][\(set)][\(loaded)][\(name)][\(value)]")
			i += 1
		}
		print("[ ======================== ]")
	}
}