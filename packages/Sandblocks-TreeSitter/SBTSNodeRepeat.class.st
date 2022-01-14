Class {
	#name : #SBTSNodeRepeat,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'multiple',
		'required',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> copy [

	^ super copy multiple: self multiple required: self required element: self element
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> multiple [

	^ multiple
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> multiple: aBoolean required: anotherBoolean element: aMorph [

	multiple := aBoolean.
	required := anotherBoolean.
	element := aMorph
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> printOn: aStream [

	element printOn: aStream.
	(multiple and: [required]) ifTrue: [^ aStream nextPut: $+].
	(multiple and: [required not]) ifTrue: [^ aStream nextPut: $*].
	aStream nextPut: $?
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> required [

	^ required
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> resultsFor: aParser [

	| results |
	results := self element resultsFor: aParser.
	results = #noMatch ifTrue: [^ self required ifTrue: [#noMatch] ifFalse: [{self copy}]].
	^ results collect: [:result | self copy addChild: result]
]
