Class {
	#name : #SBPyMensaExample,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyMensaExample class >> buildOn: aBuilder [

	aBuilder addSectionHeader: 'Meta'.
	aBuilder
		addBlock: 'example'
		as: ((SBPython parseExpression: '{"_sb_example": "example", "args": lambda: []}') applyReplacement: SBExample2).
	aBuilder addBlock: 'memoize' as: (SBMemoize2 pythonFor: 'expr').
	
	aBuilder addSectionHeader: 'Schemas'.
	aBuilder addText: 'Mensa'.
	aBuilder
		addBlock: 'mensa schema'
		as: ((SBPython parseWithPlaceholders: '{"name": _name, "location": _location, "meals": _meals}') applyReplacement: SBDictTable).
	
	aBuilder addText: 'Meal'.
	aBuilder
		addBlock: 'meal schema'
		as: (((SBPython parseWithPlaceholders: '{"name": _name, "ingredients": _ingredients, "price": _prices}') applyReplacement: SBDictTable) valueCellWidth: 150).
	
	aBuilder addText: 'Price'.
	aBuilder
		addBlock: 'price schema'
		as: ((SBPython parseWithPlaceholders: '{"student": _price_students, "staff": _price_staff, "guest": _price_guest}') applyReplacement: SBDictTable).
	
	aBuilder addSectionHeader: 'Helper'.
	aBuilder
		addBlock: 'map ingredients'
		as: ((SBPython parseWithPlaceholders: '{"gluten": _bool, "lactose": _bool, "meat": _bool}[_field]') applyReplacement: SBDictMapper)
]

{ #category : #'as yet unclassified' }
SBPyMensaExample class >> language [

	^ SBPython
]
