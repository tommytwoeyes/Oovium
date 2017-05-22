//
//  Tower.swift
//  Oovium
//
//  Created by Joe Charlier on 10/1/16.
//  Copyright © 2016 Aepryus Software. All rights reserved.
//

import Foundation

public enum TowerState {
	case open, calced, uncalced, invalid
}
enum CalcState {
	case notReady, progress, cached
}

public final class Tower: Hashable, CustomStringConvertible {
	public var name: String
	public var index: UInt8 = 0
	var task: UnsafeMutablePointer<Task>?
//	var taskS: TaskS?
	var token: Token!
	
	var upstream: Set<Tower> = Set<Tower>()
	var downstream: Set<Tower> = Set<Tower>()

	public var gateTo: Tower?
	public var thenTo: Tower?
	public var elseTo: Tower?
	public var gate: Tower?

	var state: TowerState = .open
//	var stopper: NSObject?
	
	init() {
		name = "[\(arc4random_uniform(99999999))]"
	}
	public init (task: UnsafeMutablePointer<Task>?) {
		name = "[\(arc4random_uniform(99999999))]"
		self.task = task
	}
	
	func signal () {}
	
	private var _orbit: Tower?
	var orbit: Tower? {
		set {_orbit = newValue}
		get {
//			if (stopper != nil) {return nil}
			if let orbit = orbitUp() {return orbit}
//			if let orbit = orbitDown() {return orbit}
			return nil
		}
	}
	
	private func orbitUp() -> Tower? {
		if let orbit = orbit {return orbit}
		for tower in upstream
			{if let orbit = tower.orbitUp() {return orbit}}
		return nil
		
	}
//	private func orbitDown() -> Tower? {
//		if let orbit = orbit {return orbit}
//		for tower in downstream
//			{if let orbit = tower.orbitDown() {return orbit}}
//		return nil
//	}
	
	public func attach (_ tower: Tower) {
		downstream.insert(tower)
		tower.upstream.insert(self)
	}
	func detach (_ tower: Tower) {
		downstream.remove(tower)
		tower.upstream.remove(self)
	}
	func clear() {
		upstream.removeAll()
		downstream.removeAll()
	}
	
	func wire (chain: Chain, memory: UnsafeMutablePointer<Memory>) {
		
		var lambda: UnsafeMutablePointer<Lambda>
		
		lambda = chain.compile(memory: memory)
//		let lambdaTask = LambdaTask(label: token.tag.key, command: "\(token.tag.key) = \(chain.display)", lambda: lambdaC)
		let lambdaTask = AETaskCreateLambda(lambda)
		lambdaTask?.pointee.label = token.tag.key.toInt8()
		lambdaTask?.pointee.command = "\(token.tag.key) = \(chain.display)".toInt8()
		
//		lambdaTask.load(/*label: token.tag.key, command: "\(token.tag.key) = \(chain.display)", */)
		
		task = lambdaTask

		index = AEMemoryIndexForName(memory, token.tag.key.toInt8())
//		lambda.vi = index
		lambda.pointee.vi = UInt8(index)
		for token in chain.tokens {
			let tower = Tower.tower(token: token)
			if let tower = tower {
				tower.attach(self)
			}
		}
	}
	
	func towersDestined (for target: Tower) -> Set<Tower> {
		if self == target {return [self]}
		
		var result = Set<Tower>()
		for tower in downstream {
			result.formUnion(tower.towersDestined(for: target))
		}
		if result.count > 0 && self.task != nil {
			result.insert(self)
		}
		return result
	}
//	private func possiblePaths (for target: Tower) -> Satyr<Tower> {
//		if self == target {
//			var satyr = Satyr<Tower>()
//			satyr.array.append([self])
//		}
//		
//		var satyr = Satyr<Tower>()
//		if task != nil {
//			satyr.array.append([self])
//		} else {
//			satyr.array.append([])
//		}
//		
//		if gateTo == nil {
//			for tower in downstream {
//				satyr.incorporate(tower.possiblePaths(for: target))
//			}
//		} else {
//			for tower in downstream {
//				let downSatyr = tower.possiblePaths(for: target)
//				for set in downSatyr.array {
//					satyr.array.append(set)
//				}
//			}
//		}
//		
//		return satyr
//	}
	func stronglyLinked (to target: Tower, override: Tower?) -> Bool {
		if self == target || self == override {return true}
		if gate != nil {return false}
		if let gateTo = self.gateTo {
			return gateTo.stronglyLinked(to: target, override: override)
		} else {
			for tower in downstream {
				if tower.stronglyLinked(to: target, override: override) {
					return true
				}
			}
			return false
		}
	}
	func towersStronglylinked (for target: Tower, override: Tower?) -> Set<Tower> {
		let towers = towersDestined(for: target)
		var result = Set<Tower>()
		for tower in towers {
			if tower.stronglyLinked(to: target, override: override) {
				result.insert(tower)
			}
		}
		return result
	}
	func towersStronglylinked (for target: Tower) -> Set<Tower> {
		let result = towersStronglylinked(for: target, override: nil)
		
		let satyr = Satyr<Tower>()
		satyr.array.append(result)
		
		for tower in result {
			if tower.gateTo != nil {
				let gateSatyr = Satyr<Tower>()
				for branch in tower.downstream {
					if tower.gateTo == branch {continue}
					gateSatyr.array.append(towersStronglylinked(for: target, override: branch))
				}
				satyr.incorporate(gateSatyr)
			}
		}
		
		return satyr.intersection()
	}

// Evaluate ========================================================================================
	private func isCalced(_ spider: Spider) -> Bool {
		return spider.memory.pointee.slots[Int(index)].loaded != UInt8(0)
	}
	func ping (_ spider: inout Spider) -> Bool {
		if isCalced(spider) {return false}
		
		if let gate = gate {
			if !gate.isCalced(spider) || !spider.needed.contains(gate) {return false}
		}
		
//		var needed: Bool = false
//		for tower in downstream {
//			if spider.needed.contains(tower) {
//				needed = true
//				break
//			}
//		}
//		if !needed {return false}
		
		for tower in upstream {
			if tower.task == nil {continue}
			if !tower.isCalced(spider) {return false}
		}
		
		spider.memory.pointee.slots[Int(index)].loaded = 1
		return true
	}
	
	func calculate (_ memory: UnsafeMutablePointer<Memory>) -> CalcState {
		if state != .open {return .cached}
		
		for tower in upstream {
			if tower.state == .open {
				return .notReady
			} else if tower.state == .uncalced {
				state = .uncalced
				return .progress
			}
		}

		_ = AETaskExecute(task, memory)
		state = .calced
		AEMemoryFix(memory, index)
		
		return .progress
	}
	
	public static func printTowers (_ towers: Set<Tower>) {
		var sb = String()
		sb.append("[ Towers =================================== ]\n")
		for tower in towers {
			print("\(tower)")
		}
//		for tower in towers  {
//			if let taskS = tower.taskS {
//				sb.append("  \(taskS.label) : \(taskS.command)\n")
//			}
//		}
		sb.append("[ ========================================== ]\n\n")
		print("\(sb)")
	}

// Hashable ========================================================================================
	public static func == (left: Tower, right: Tower) -> Bool {
		return left === right
	}
	public var hashValue: Int {
		return name.hashValue
	}

	
// CustomStringConvertible ====================================================================
	private var display: String {
		return "\(name)"
	}
	public var description: String {
		var sb: String = ""

		sb.append("Tower [\(display) : \(state)\n")
		sb.append("\tupstream:\n")
		for tower in upstream
			{sb.append("\t\t\(tower.display)\n")}
		sb.append("\tdownstream:\n")
		for tower in downstream
			{sb.append("\t\t\(tower.display)\n")}

		return sb;
	}
	
// Static ==========================================================================================
	static var lookup = [Token:Tower]()
	static func link (token: Token, tower: Tower) {
		Tower.lookup[token] = tower
	}
	static func tower (token: Token) -> Tower? {
		return Tower.lookup[token]
	}
}
