Class {
	#name : #SBTSNodeSymbol,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'type'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> allSuperTypesDo: aBlock [

	aBlock value: self.
	super allSuperTypesDo: aBlock
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> body [

	^ self factory bodyNodeForRule: self type
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> copy [

	^ super copy
		type: self type factory: factory;
		addAllMorphs: (self submorphs collect: #copy)
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> printOn: aStream [

	aStream nextPutAll: type
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> resultsFor: aParser [

	| exploreBlock |
	exploreBlock := [ | results |
		results := self body resultsFor: aParser.
		results = #noMatch ifTrue: [#noMatch] ifFalse: [
			results collect: [:result |
				self assert: self hasSubmorphs not.
				self copy
					addChild: result;
					parser: result parser]]].
	^ aParser
		memoizationFor: self type
		ifPresent: [:blocks |
			" we may not actually ever want left-recursion, because these blocks will be composed of a wrapper block and a basic block, and we always want to choose the basic block and offer the user to expand the basic block to the more complicated construct. "
			blocks = #recur ifTrue: [#noMatch] ifFalse: [
				blocks = #noMatch ifTrue: [#noMatch] ifFalse: [ | result |
					result := blocks collect: #copy.
					aParser peek = (Character value: 0) ifTrue: [
						aParser next.
						result first parser: aParser].
					result]]]
		ifAbsentPut: exploreBlock
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> type [

	^ type
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> type: aString factory: aFactory [

	type := aString.
	factory := aFactory
]
