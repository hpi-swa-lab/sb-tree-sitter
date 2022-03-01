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
SBMetaGrammarHandler >> insertStatementAboveOrBelow: anAboveBoolean [

	| newStatement topMost body |
	" try to find a suitable place to insert a statement, either above or below the current statement,
	  or at the start of the containing block body, or at the start of first block body in the artefact "
	topMost := self block.
	[topMost parentSandblock notNil and: [topMost parentSandblock isBlockBody not]] whileTrue: [topMost := topMost parentSandblock].
	(topMost hasOwner: self block containingArtefact) ifFalse: [topMost := nil].
	body := ((topMost isNil or: [topMost parentSandblock isNil])
		ifFalse: [topMost parentSandblock]
		ifTrue: [self block containingArtefact nextBlockThat: [:b | b isBlockBody]]) ifNil: [self block isBlockBody ifTrue: [self block] ifFalse: [^ self]].
	(body = self block containingFloat or: [body hasOwner: self block containingFloat]) ifFalse: [^ self].
	newStatement := (body repeaterChildThat: [:r | r multiple]) ifNotNil: [:c | c element instantiate].
	((body repeaterChildThat: [:r | r multiple]) ifNotNil: [:c | c insertCommandRequest: newStatement near: topMost before: anAboveBoolean]) ifNotNil: [:cmd | self block sandblockEditor do: cmd]
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> newNullBlock [

	^ SBTSUnknown new grammarHandler: self
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> startOverrideInput: anEvent in: anEditor [

	anEditor mode = #input ifTrue: [self block tryInterpretInput: anEvent keyCharacter asString before: false].
	anEditor mode = #command ifTrue: [
		anEditor selection changeToUnknown.
		anEditor mode = #input ifTrue: [anEditor selection keyStroke: anEvent]]
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> textContentsForCopy [
	"invoking the pretty printer here is rather expensive (e.g. when deleting multiple stmts, so just use the regular sourceString"

	^ self block sourceString
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> wrapWithWatch [
	<action>

	^ self block wrapWithWatch
]

{ #category : #'as yet unclassified' }
SBMetaGrammarHandler >> writeSourceOn: aStream for: aBlock [

	aBlock writeMetaSourceOn: aStream
]
