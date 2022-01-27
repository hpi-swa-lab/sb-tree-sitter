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

{ #category : #copying }
SBTSNodeRepeat >> basicCopy [

	^ super basicCopy multiple: self multiple required: self required element: self element
]

{ #category : #query }
SBTSNodeRepeat >> childrenForQueryDo: aBlock [

	self submorphsDo: [:m | m childrenForQueryDo: aBlock]
]

{ #category : #accessing }
SBTSNodeRepeat >> element [

	^ element
]

{ #category : #accessing }
SBTSNodeRepeat >> maxChildren [

	^ self multiple ifTrue: [900000000] ifFalse: [1]
]

{ #category : #accessing }
SBTSNodeRepeat >> multiple [

	^ multiple
]

{ #category : #accessing }
SBTSNodeRepeat >> multiple: aBoolean required: anotherBoolean element: aMorph [

	multiple := aBoolean.
	required := anotherBoolean.
	element := aMorph
]

{ #category : #printing }
SBTSNodeRepeat >> printOn: aStream [

	element printOn: aStream.
	(multiple and: [required]) ifTrue: [^ aStream nextPut: $+].
	(multiple and: [required not]) ifTrue: [^ aStream nextPut: $*].
	aStream nextPut: $?
]

{ #category : #accessing }
SBTSNodeRepeat >> required [

	^ required
]

{ #category : #parsing }
SBTSNodeRepeat >> resultsFor: aParser [

	| results |
	results := self element resultsFor: aParser.
	results = #noMatch ifTrue: [^ self required ifTrue: [#noMatch] ifFalse: [{self makeConcrete parser: aParser}]].
	^ results collect: [:result | self makeConcrete addChild: result]
]

{ #category : #parsing }
SBTSNodeRepeat >> takeNodesFrom: aParser [

	| results |
	" parse multiple "
	self flag: #todo.
	results := self element takeNodesFrom: aParser.
	results = #noMatch ifTrue: [^ self required ifTrue: [#noMatch] ifFalse: [{self makeConcrete parser: aParser}]].
	^ results collect: [:result | self makeConcrete addChild: result]
]

{ #category : #printing }
SBTSNodeRepeat >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
