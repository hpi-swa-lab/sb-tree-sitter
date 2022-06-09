Class {
	#name : #SBTSIdentifierHighlight,
	#superclass : #SBTSListener,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSIdentifierHighlight class >> matches: aBlock [

	^ aBlock type = 'identifier'
]

{ #category : #'as yet unclassified' }
SBTSIdentifierHighlight class >> wasDeselected: aBlock [

	aBlock language
		usagesOf: aBlock
		do: [:usage | usage detachDecorators: SBHighlightDecorator]
]

{ #category : #'as yet unclassified' }
SBTSIdentifierHighlight class >> wasSelected: aBlock [

	aBlock language
		usagesOf: aBlock
		do: [:usage | usage attachDecorator: SBHighlightDecorator new]
]
