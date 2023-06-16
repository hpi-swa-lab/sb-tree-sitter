Class {
	#name : #SBTSIdentifierHighlight,
	#superclass : #SBTSListener,
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'as yet unclassified' }
SBTSIdentifierHighlight class >> matches: aBlock [

	^ aBlock language isIdentifier: aBlock
]

{ #category : #'as yet unclassified' }
SBTSIdentifierHighlight class >> wasDeselected: aBlock [

	aBlock sandblockEditor ifNil: [^ self].
	
	aBlock semantics
		usagesOf: aBlock
		do: [:usage | usage detachDecorators: SBHighlightDecorator]
]

{ #category : #'as yet unclassified' }
SBTSIdentifierHighlight class >> wasSelected: aBlock [

	aBlock semantics
		usagesOf: aBlock
		do: [:usage | usage attachDecorator: SBHighlightDecorator new]
]
