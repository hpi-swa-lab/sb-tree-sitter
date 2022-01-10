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
SBInlineBlockReplace >> writeSourceOn: aStream [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBInlineBlockReplace >> writeSourceOn: aStream indent: aNumber [

	^ self writeSourceOn: aStream
]
