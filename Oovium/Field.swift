//
//  Field.swift
//  Oovium
//
//  Created by Joe Charlier on 12/30/16.
//  Copyright © 2016 Aepryus Software. All rights reserved.
//

import Foundation

final class Field: Domain {
	var name: String = ""
	var def: Def = RealDef.def

// Domain ==========================================================================================
	override func properties() -> [String] {
		return super.properties() + ["name", "def"]
	}
}
