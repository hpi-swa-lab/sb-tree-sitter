Class {
	#name : #SBTSNodeSymbol,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'type'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #hierarchy }
SBTSNodeSymbol >> allSuperTypesDo: aBlock [

	aBlock value: self.
	super allSuperTypesDo: aBlock
]

{ #category : #copying }
SBTSNodeSymbol >> basicCopy [

	^ super basicCopy type: self type factory: factory
]

{ #category : #testing }
SBTSNodeSymbol >> blockInlined [

	^ factory shouldBlockInline: self type
]

{ #category : #accessing }
SBTSNodeSymbol >> bodyTemplate [

	^ self factory bodyNodeForRule: self type
]

{ #category : #build }
SBTSNodeSymbol >> build [

	^ (self isSuperType or: [false and: [self blockInlined]])
		ifTrue: [
			self children gather: [:child |
				child build
					do: [:res | res isTSBlock ifTrue: [res slot: self slot]];
					yourself]]
		ifFalse: [
			self assert: self slot notNil.
			{
				SBTSBlock new
					slot: self slot;
					addAllMorphs: (self children gather: [:child | child build])}]
]

{ #category : #query }
SBTSNodeSymbol >> childrenForQueryDo: aBlock [

	self isSuperType
		ifTrue: [self firstSubmorph childrenForQueryDo: aBlock]
		ifFalse: [aBlock value: self]
]

{ #category : #hierarchy }
SBTSNodeSymbol >> containingSymbol [

	
]

{ #category : #accessing }
SBTSNodeSymbol >> contents [

	^ (self factory ifNotNil: [:f | f containsPromotedInlineSymbol: self type] ifNil: [false])
		ifTrue: [String streamContents: [:stream | self childSandblocksDo: [:child | child contents ifNotNil: [:content | stream nextPutAll: content]]]]
		ifFalse: [super contents]
]

{ #category : #testing }
SBTSNodeSymbol >> inline [

	^ factory isNil or: [factory shouldBlockInline: self type]
]

{ #category : #statements }
SBTSNodeSymbol >> isStatementContainer [

	^ factory isStatementContainer: self type
]

{ #category : #testing }
SBTSNodeSymbol >> isSuperType [

	^ factory isSuperType: self type
]

{ #category : #testing }
SBTSNodeSymbol >> isTSSymbol [

	^ true
]

{ #category : #printing }
SBTSNodeSymbol >> printOn: aStream [

	aStream nextPutAll: type
]

{ #category : #printing }
SBTSNodeSymbol >> printSExprOn: aStream depth: aNumber short: aBoolean [

	| any |
	(aBoolean and: [self inline]) ifTrue: [^ super printSExprOn: aStream depth: aNumber short: aBoolean].
	(self field notNil and: [self inline not]) ifTrue: [
		aStream
			nextPutAll: self field;
			nextPutAll: ': '].
	aStream nextPutAll: '('.
	self inline ifTrue: [aStream nextPutAll: '['].
	aStream nextPutAll: self type.
	self inline ifTrue: [aStream nextPutAll: ']'].
	any := false.
	self
		childSymbolsDo: [:morph |
			any ifFalse: [any := true].
			aStream crtab: aNumber + 1.
			morph printSExprOn: aStream depth: aNumber + 1 short: aBoolean]
		includeInlined: aBoolean not.
	any ifTrue: [aStream crtab: aNumber].
	aStream nextPutAll: ')'
]

{ #category : #parsing }
SBTSNodeSymbol >> resultsFor: aParser [

	^ aParser
		memoizationFor: self type
		ifPresent: [:blocks |
			" we may not actually ever want left-recursion, because these blocks will be composed of a wrapper block and a basic block, and we always want to choose the basic block and offer the user to expand the basic block to the more complicated construct. "
			(blocks = #recur or: [blocks = #noMatch])
				ifTrue: [#noMatch]
				ifFalse: [ | result |
					result := blocks collect: [:b | b copy].
					aParser peek = (Character value: 0) ifTrue: [
						aParser next.
						result first parser: aParser].
					result]]
		ifAbsentPut: [ | results |
			results := self bodyTemplate resultsFor: aParser.
			results = #noMatch
				ifTrue: [#noMatch]
				ifFalse: [results collect: [:result | self makeConcrete addChild: result]]]
]

{ #category : #parsing }
SBTSNodeSymbol >> takeNodesFrom: aParser [

	(self isSuperType or: [factory promotedInlineSymbols includes: self type]) ifTrue: [ | results |
		results := self bodyTemplate takeNodesFrom: aParser.
		^ results = #noMatch
			ifTrue: [#noMatch]
			ifFalse: [results collect: [:r | self makeConcrete addChild: r]]].
	
	(aParser atEnd not and: [aParser peek isString not and: [aParser peek compatibleWithType: self type]]) ifTrue: [
		^ {
			aParser next copy
				parser: aParser copy;
				field: field}].
	
	^ #noMatch
]

{ #category : #accessing }
SBTSNodeSymbol >> type [

	^ type
]

{ #category : #accessing }
SBTSNodeSymbol >> type: aString factory: aFactory [

	type := aString asSymbol.
	factory := aFactory
]

{ #category : #printing }
SBTSNodeSymbol >> writeSourceOn: aStream indent: aNumber [

	self firstSubmorph writeSourceOn: aStream indent: aNumber
]
