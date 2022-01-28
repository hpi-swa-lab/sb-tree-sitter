Class {
	#name : #SBTSNodeAlias,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'alias',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #accessing }
SBTSNodeAlias >> alias [

	^ alias
]

{ #category : #accessing }
SBTSNodeAlias >> alias: aString [

	alias := aString asSymbol
]

{ #category : #copying }
SBTSNodeAlias >> basicCopy [

	^ super basicCopy
		element: self element;
		alias: self alias
]

{ #category : #query }
SBTSNodeAlias >> childrenForQueryDo: aBlock [

	self firstSubmorph childrenForQueryDo: aBlock
]

{ #category : #accessing }
SBTSNodeAlias >> element [

	^ element
]

{ #category : #accessing }
SBTSNodeAlias >> element: anElement [

	element := anElement
]

{ #category : #printing }
SBTSNodeAlias >> printOn: aStream [

	aStream nextPut: $(.
	aStream nextPutAll: self alias.
	aStream nextPut: $=.
	self element printOn: aStream.
	aStream nextPut: $)
]

{ #category : #parsing }
SBTSNodeAlias >> resultsFor: aParser [

	| results |
	results := self element resultsFor: aParser.
	^ results = #noMatch
		ifTrue: [#noMatch]
		ifFalse: [results collect: [:child | self makeConcrete addChild: child]]
]

{ #category : #parsing }
SBTSNodeAlias >> takeNodesFrom: aParser [

	^ (aParser atEnd not and: [
		aParser peek isString not and: [
			SBToggledCode comment: '' active: 1 do: {
				[(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]].
				[aParser peek type = self alias or: [(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]]]}]])
		ifTrue: [
			{
				self makeConcrete
					addChild: aParser next copy;
					parser: aParser copy}]
		ifFalse: [#noMatch]
]

{ #category : #accessing }
SBTSNodeAlias >> unpackAlias [

	^ self element isTSSymbol
		ifTrue: [self element bodyTemplate]
		ifFalse: [self element]
]

{ #category : #printing }
SBTSNodeAlias >> writeSourceOn: aStream indent: aNumber [

	self firstSubmorph writeSourceOn: aStream indent: aNumber
]
