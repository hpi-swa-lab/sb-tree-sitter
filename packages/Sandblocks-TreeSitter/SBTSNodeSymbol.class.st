Class {
	#name : #SBTSNodeSymbol,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'type'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> body [

	^ self factory bodyNodeForRule: self type
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> copy [

	^ super copy type: self type factory: factory
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> printOn: aStream [

	aStream nextPutAll: type
]

{ #category : #'as yet unclassified' }
SBTSNodeSymbol >> resultsFor: aParser [

	^ aParser memoizationFor: self type ifPresent: [:block | block veryDeepCopy] ifAbsentPut: [ | results |
		results := self body resultsFor: aParser.
		results = #noMatch ifTrue: [#noMatch] ifFalse: [
			results collect: [:result |
				self copy
					addChild: result;
					parser: result parser]]]
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
