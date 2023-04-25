Class {
	#name : #SBPyMensaExample,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyMensaExample class >> buildOn: aBuilder [

	aBuilder addHeader: 'Data Mapper'.
	
	aBuilder addSectionHeader: 'Meta'.
	aBuilder
		addBlock: 'example'
		as: ((SBPython parseExpression: '{"_sb_example": "example", "args": lambda: []}') applyReplacement: SBExample2).
	aBuilder addBlock: 'memoize' as: (SBMemoize2 pythonFor: 'expr').
	aBuilder addBlock: 'function' as: (SBPython parseWithPlaceholders: 'def _name():
	return _expr').
	aBuilder addBlock: 'in' as: (SBPython parseWithPlaceholders: '_element in _list').
	
	aBuilder addSectionHeader: 'Schemas'.
	aBuilder addText: 'Mensa'.
	aBuilder
		addBlock: 'mensa schema'
		as: (((SBPython parseWithPlaceholders: '{"name": _name, "location": _location, "days": _days}') applyReplacement: SBDictTable) valueCellWidth: 400).
	
	aBuilder addText: 'Day'.
	aBuilder
		addBlock: 'day schema'
		as: (((SBPython parseWithPlaceholders: '{"date": _date, "meals": _meals}') applyReplacement: SBDictTable) valueCellWidth: 300).
	
	aBuilder addText: 'Meal'.
	aBuilder
		addBlock: 'meal schema'
		as: (((SBPython parseWithPlaceholders: '{"name": _name, "ingredients": _ingredients, "price": _prices}') applyReplacement: SBDictTable) valueCellWidth: 200).
	
	aBuilder addText: 'Price'.
	aBuilder
		addBlock: 'price schema'
		as: (((SBPython parseWithPlaceholders: '{"student": _price_students, "staff": _price_staff, "guest": _price_guest}') applyReplacement: SBDictTable) valueCellWidth: 50).
	
	aBuilder addSectionHeader: 'Helper'.
	aBuilder
		addBlock: 'map ingredients'
		as: ((SBPython parseWithPlaceholders: '{_name: "gluten", _name: "lactose", _name: "meat"}[_field]') applyReplacement: SBDictMapper)
]

{ #category : #'as yet unclassified' }
SBPyMensaExample class >> context [

	^ SBInterfaces never
]

{ #category : #'as yet unclassified' }
SBPyMensaExample class >> language [

	^ SBPython
]
