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
SBMetaGrammarHandler >> promptMetaTransform [
	<action>

	
	self block
		tryInterpretInput: ((UIManager default request: 'type operator') ifEmpty: [^ self])
		before: ActiveEvent shiftPressed not
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> startOverrideInput: anEvent in: anEditor [

	self block tryInterpretInput: anEvent keyCharacter asString before: false
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> writeSourceOn: aStream for: aBlock [

	aBlock writeMetaSourceOn: aStream
]
