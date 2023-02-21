Class {
	#name : #SBTSPlaceholderBlock,
	#superclass : #SBTSUnknownBlock,
	#category : #'Sandblocks-TreeSitter-UI'
}

{ #category : #'as yet unclassified' }
SBTSPlaceholderBlock >> placeholderLengthLimit [

	^ 20
]

{ #category : #'as yet unclassified' }
SBTSPlaceholderBlock >> valid [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSPlaceholderBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream nextPutAll: '_a'
]
