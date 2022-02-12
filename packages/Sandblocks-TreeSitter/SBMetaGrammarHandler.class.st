Class {
	#name : #SBMetaGrammarHandler,
	#superclass : #SBGrammarHandler,
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> characterCanStartInput: aCharacter [

	^ true
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> newNullBlock [

	^ SBTSUnknown new grammarHandler: self
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> startOverrideInput: anEvent in: anEditor [

	self block tryInterpretInput: anEvent keyCharacter asString before: false
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> textContentsForCopy [
	"invoking the pretty printer here is rather expensive (e.g. when deleting multiple stmts, so just use the regular sourceString"

	^ self block sourceString
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> writeSourceOn: aStream for: aBlock [

	aBlock writeMetaSourceOn: aStream
]
