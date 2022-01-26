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

{ #category : #accessing }
SBTSNodeSymbol >> bodyTemplate [

	^ self factory bodyNodeForRule: self type
]

{ #category : #printing }
SBTSNodeSymbol >> printOn: aStream [

	aStream nextPutAll: type
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
			results = #noMatch ifTrue: [#noMatch] ifFalse: [
				results collect: [:result |
					self makeConcrete
						addChild: result;
						parser: result parser]]]
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
