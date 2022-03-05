Class {
	#name : #SBTSTestLanguage,
	#superclass : #SBMetaBlockFactory,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSTestLanguage >> add: aString rule: aBlock [

	(nodesCache ifNil: [nodesCache := Dictionary new])
		at: aString
		put: aBlock
]
