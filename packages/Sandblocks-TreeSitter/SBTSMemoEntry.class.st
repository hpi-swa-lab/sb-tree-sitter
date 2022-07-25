Class {
	#name : #SBTSMemoEntry,
	#superclass : #Object,
	#instVars : [
		'answer'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> anyResultIsAtEndFor: aParser [

	self isLeftRecursion ifTrue: [^ false].
	^ self parsers anySatisfy: [:p | p position = aParser limit]
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> getBlocksOrMarkRecursionFrom: aSymbol stack: aCollection max: aNumber [

	^ self isLeftRecursion
		ifTrue: [
			self setLeftRecursionDetectedFrom: aSymbol stack: aCollection.
			{}]
		ifFalse: [
			self parsers select: [:p |
				((p blocks first children ifNotEmpty: [:c | c first] ifEmpty: [p blocks first]) slot parentThat: [:node | node isTSPrecedence])
					ifNotNil: [:precedence | precedence canExpandInStack: aCollection, {aSymbol}]
					ifNil: [true]]]
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> isLeftRecursion [

	^ answer class = SBTSRecursion
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> leftRecursionDetected [

	self assert: self isLeftRecursion.
	^ answer head notNil
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> lr [

	self assert: self isLeftRecursion.
	^ answer
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> lr: aRecursion [

	self assert: aRecursion class = SBTSRecursion.
	answer := aRecursion
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> parsers [

	self assert: self isLeftRecursion not.
	^ answer
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> parsers: aCollection symbol: aSymbol [

	self assert: (aCollection allSatisfy: [:p | p class = SBTSMemoizedBlocks]).
	"self assert: (aSymbol isBlockInlinedInParent or: [(aCollection allSatisfy: [:memo | memo blocks first slot lastNode type = aSymbol type])])."
	answer := aCollection collect: [:parser | parser copy]
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> printOn: aStream [

	aStream nextPutAll: self className.
	self isLeftRecursion
		ifTrue: [
			aStream nextPutAll: (self leftRecursionDetected
				ifTrue: ['(recurDetected)']
				ifFalse: ['(recurMarker)'])]
		ifFalse: [
			aStream
				nextPut: $(;
				print: self parsers;
				nextPut: $)]
]

{ #category : #'as yet unclassified' }
SBTSMemoEntry >> setLeftRecursionDetectedFrom: aSymbol stack: aCollection [

	| stack |
	self assert: self isLeftRecursion.
	stack := (aCollection reversed first: (aCollection reversed findFirst: [:el | el type = aSymbol type]) - 1) collect: [:t | t type].
	
	answer head ifNotNil: [answer addInvolved: stack] ifNil: [
		answer
			head: aSymbol type;
			allowedSymbols: {};
			involvedSymbols: stack asSet]
]
