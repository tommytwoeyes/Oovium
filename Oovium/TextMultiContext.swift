//
//  TextMultiContext.swift
//  Oovium
//
//  Created by Joe Charlier on 9/8/17.
//  Copyright © 2017 Aepryus Software. All rights reserved.
//

import Foundation

class TextMultiContext: Context {
	init() {
		super.init(schematic: Schematic(rows: 4, cols: 1))
		
		self.schematic.add(row: 0, col: 0, key: Key(text: NSLocalizedString("copy", comment: ""), uiColor: UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1), {}))
		self.schematic.add(row: 1, col: 0, key: Key(text: NSLocalizedString("color", comment: ""), uiColor: UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1), {}))
		self.schematic.add(row: 2, col: 0, key: Key(text: NSLocalizedString("shape", comment: ""), uiColor: UIColor(red: 0.6, green: 0.7, blue: 0.8, alpha: 1), {}))
		self.schematic.add(row: 3, col: 0, key: Key(text: NSLocalizedString("delete", comment: ""), uiColor: UIColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1), {}))
		
		self.schematic = schematic
	}
	required init? (coder aDecoder: NSCoder) {fatalError()}
}
