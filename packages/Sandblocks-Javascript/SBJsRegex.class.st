Class {
	#name : #SBJsRegex,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRegex class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(regex (regex_pattern) @regex)' sample: '/abc/'>

	^ aBlock value: (aDictionary at: 'regex') value: (self new regex: (aDictionary at: 'regex') contents)
]

{ #category : #'as yet unclassified' }
SBJsRegex >> build [
	<lang: #javascript match: '(regex (regex_pattern) @root)' sample: '/abc/'>

	self
		layoutPolicy: SBAlgebraLayout new;
		addMorphBack: (self
			createBinding: [:c | SBRegex parse: (c at: 'root') sourceString]
			update: [:c :m | (c at: 'root') contents: m sourceString])
]

{ #category : #'as yet unclassified' }
SBJsRegex >> initialize [

	super initialize.
	
	
]

{ #category : #'as yet unclassified' }
SBJsRegex >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: {self firstSubmorph layoutCommands}
]
