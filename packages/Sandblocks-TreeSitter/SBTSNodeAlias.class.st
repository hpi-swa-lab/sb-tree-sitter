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

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> allChildrenDo: aBlock [

	aBlock value: self.
	self element allChildrenDo: aBlock
]

{ #category : #'as yet unclassified' }
SBTSNodeAlias >> buildEmpty [

	^ self element buildEmpty
]

{ #category : #parsing }
SBTSNodeAlias >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	self element cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock
]

{ #category : #accessing }
SBTSNodeAlias >> element [

	^ element
]

{ #category : #accessing }
SBTSNodeAlias >> element: anElement [

	element := anElement.
	anElement parent: self
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

	^ self element resultsFor: aParser
]

{ #category : #parsing }
SBTSNodeAlias >> takeNodesFrom: aParser [

	^ (aParser atEnd not and: [
		aParser peek isString not and: [
			SBToggledCode comment: '' active: 1 do: {
				[(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]].
				[aParser peek type = self alias or: [(aParser peek isKindOf: self class) and: [aParser peek alias = self alias]]]}]])
		ifTrue: [
			aParser next.
			{aParser copy addSlot: self}]
		ifFalse: [#noMatch]
]

{ #category : #accessing }
SBTSNodeAlias >> unpackAlias [

	^ self element isTSSymbol
		ifTrue: [self element bodyTemplate]
		ifFalse: [self element]
]
