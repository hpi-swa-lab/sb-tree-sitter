Class {
	#name : #SBTSNodeContextSensitiveText,
	#superclass : #SBTSNodeText,
	#instVars : [
		'validCheck'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeContextSensitiveText >> characterValid: aCharacter in: aSiblingsCollection [

	^ validCheck value: aSiblingsCollection value: aCharacter
]

{ #category : #'as yet unclassified' }
SBTSNodeContextSensitiveText >> prefixValidFor: aString in: aSiblingsCollection [

	aString do: [:c | (validCheck value: aSiblingsCollection value: c) ifFalse: [^ false]].
	^ true
]

{ #category : #'as yet unclassified' }
SBTSNodeContextSensitiveText >> resultsFor: aParser [

	| contents |
	contents := String streamContents: [:stream | [aParser peek isCharacter and: [validCheck value: aParser blocks value: aParser peek]] whileTrue: [stream nextPut: aParser next]].
	aParser addBlock: (SBTSParseNode kind: #text slot: (SBTSSlot with: self) contents: (String withAll: contents)).
	^ {aParser}
]

{ #category : #'as yet unclassified' }
SBTSNodeContextSensitiveText >> validCheck: aClosure [

	validCheck := aClosure
]

{ #category : #'as yet unclassified' }
SBTSNodeContextSensitiveText >> validFor: aString in: aSiblingsCollection [

	aString do: [:c | (validCheck value: aSiblingsCollection value: c) ifFalse: [^ false]].
	^ true
]
