"
Replaces all python booleans with checkboxes.
"
Class {
	#name : #SBPyBool,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyBool class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '[(true) (false)] @bool' sample: 'True'>

	(aDictionary at: 'bool') type = 'true'
		ifTrue: [^ aBlock value: (aDictionary at: 'bool') value: (self new factory: (aDictionary at: 'bool') factory; replaceWithChecked: true)]
		ifFalse: [^ aBlock value: (aDictionary at: 'bool') value: (self new factory: (aDictionary at: 'bool') factory; replaceWithChecked: false)].
]

{ #category : #'initialize-release' }
SBPyBool >> build [
	<lang: #python match: '[(true) (false)]' sample: 'True'>

	self addMorphBack: (self createBinding: [:c | SBCheckbox new value: (c at: 'root') type = 'true'] update: [:c :m |
		self
			replaceBound: 'root'
			with: (SBPython parseExpression: (m value ifTrue: ['True'] ifFalse: ['False']))])
]
