//
//  Object.swift
//  Oovium
//
//  Created by Joe Charlier on 12/30/16.
//  Copyright © 2016 Aepryus Software. All rights reserved.
//

import Foundation

public class Object: Aexel {
	var tokens: String = ""
	
	var chain = Chain()
	
	var tower = Tower()
	
// Aexel ===========================================================================================
	override func plugIn () {
		tower.name = String(format: "I%05d", iden)
		tower.token = Token.token(type: .variable, tag: Tag.tag(key: tower.name))
		aether.link(tower)
	}
	override func wire (_ memory: Memory) {
		chain = Chain(string: tokens)
		tower.wire(chain:chain, memory:memory)
	}
	override func towers () -> [Tower] {
		return [tower]
	}
	
// Domain ==========================================================================================
	override func properties () -> [String] {
		return super.properties() + ["tokens"]
	}
}