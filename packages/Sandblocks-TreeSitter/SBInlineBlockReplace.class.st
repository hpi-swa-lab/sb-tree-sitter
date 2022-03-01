Class {
	#name : #SBInlineBlockReplace,
	#superclass : #SBInlineBlockSymbol,
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> buildCopy [

	^ self veryDeepCopy
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> childrenForQueryDo: aBlock [

	
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> childrenIn: anExplore [

	^ #()
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> factory [

	^ factory ifNil: [self owner factory]
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> firstDifferingBlocksWith: aMorph do: aBlock [

	self class = aMorph class ifFalse: [^ aBlock value: self value: aMorph].
	self type = aMorph type ifFalse: [^ aBlock value: self value: aMorph].
	^ nil
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> hasSameContentsAs: aBlock [

	^ aBlock class = self class
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> initialize [

	super initialize.
	
	self
		layoutPolicy: TableLayout new;
		cellPositioning: #topLeft
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> inline [

	^ false
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> layoutCommands [

	^ SBAlgebraCommand morph data: self
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> ownerWithColor [

	^ self
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> printTitleOn: aStream [

	aStream nextPutAll: self className
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> showCode [
	<action>

	| path current statement new |
	statement := self containingStatement ifNil: [self parentSandblock].
	path := Array streamContents: [:stream |
		current := self.
		[current ~= statement] whileTrue: [
			stream nextPut: current childIndex.
			current := current parentSandblock.
			self
				assert: (current isKindOf: SBInlineBlockReplace) not
				description: 'nested replacements currently not supported']].
	new := self factory class parseElement: statement sourceString.
	path do: [:index | new := new childSandblocks at: index].
	
	self sandblockEditor do: (SBReplaceCommand new target: self replacer: new)
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> writeSourceOn: aStream [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> writeSourceOn: aStream indent: aNumber [

	^ self writeSourceOn: aStream
]
