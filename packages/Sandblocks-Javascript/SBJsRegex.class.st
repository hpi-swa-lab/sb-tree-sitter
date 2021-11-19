Class {
	#name : #SBJsRegex,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRegex class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(regex (regex_pattern) @regex)' sample: '/abc/'>

	^ aBlock value: (aDictionary at: 'regex') value: (self new regex: (aDictionary at: 'regex') contents)
]

{ #category : #'as yet unclassified' }
SBJsRegex >> initialize [

	super initialize.
	
	self layoutPolicy: SBAlgebraLayout new
]

{ #category : #'as yet unclassified' }
SBJsRegex >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: {self firstSubmorph layoutCommands}
]

{ #category : #'as yet unclassified' }
SBJsRegex >> regex: aString [

	self addMorphBack: ((SBRegex parse: aString) hResizing: #shrinkWrap)
]

{ #category : #'as yet unclassified' }
SBJsRegex >> writeSourceOn: aStream [

	self firstSubmorph writeSourceOn: aStream
]
