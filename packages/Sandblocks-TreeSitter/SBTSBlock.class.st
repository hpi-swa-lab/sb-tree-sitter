Class {
	#name : #SBTSBlock,
	#superclass : #SBBlock,
	#instVars : [
		'slot'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSBlock >> currentTextMorph [

	self submorphsDo: [:m | (m isKindOf: SBOwnTextMorph) ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBlock >> cursorPositionsDo: aBlock shallow: aBoolean [

	false ifTrue: [^ super cursorPositionsDo: aBlock shallow: aBoolean].
	self template cursorPositionsDo: aBlock shallow: aBoolean blocks: self submorphs
]

{ #category : #'as yet unclassified' }
SBTSBlock >> factory [

	^ self slot factory
]

{ #category : #'as yet unclassified' }
SBTSBlock >> initialize [

	super initialize.
	
	self
		layoutPolicy: SBAlgebraLayout new;
		layoutInset: 8;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #testing }
SBTSBlock >> isBlockBody [

	^ self factory isStatementContainer: self type
]

{ #category : #testing }
SBTSBlock >> isTSBlock [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSBlock >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (Array streamContents: [:stream |
			self submorphs overlappingPairsDo: [:a :b |
				stream nextPut: a layoutCommands.
				(self factory hardLineBreakBetween: a and: b)
					ifTrue: [stream nextPut: SBAlgebraCommand hardLine]
					ifFalse: [(self factory softLineBreakBetween: a and: b) ifTrue: [stream nextPut: SBAlgebraCommand softLine]]].
			self hasSubmorphs ifTrue: [stream nextPut: self lastSubmorph layoutCommands]])
]

{ #category : #'as yet unclassified' }
SBTSBlock >> printOn: aStream [

	self slot ifNotNil: [slot printOn: aStream]
]

{ #category : #'as yet unclassified' }
SBTSBlock >> slot [

	^ slot
]

{ #category : #'as yet unclassified' }
SBTSBlock >> slot: aString [

	slot := aString
]

{ #category : #'as yet unclassified' }
SBTSBlock >> template [

	^ self factory bodyNodeForRule: self type
]

{ #category : #'as yet unclassified' }
SBTSBlock >> type [

	^ self slot type
]
