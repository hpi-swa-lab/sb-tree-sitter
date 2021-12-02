Class {
	#name : #SBTSFieldAccessor,
	#superclass : #ProtoObject,
	#instVars : [
		'element'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSFieldAccessor >> children [

	^ element childSandblocks collect: [:child | child access]
]

{ #category : #'as yet unclassified' }
SBTSFieldAccessor >> doesNotUnderstand: aMessage [

	aMessage selector isUnary ifTrue: [
		element childrenForQuery
			detect: [:child | child field = aMessage selector]
			ifFound: [:child | ^ child inline ifTrue: [child childSandblocks collect: [:c | c access]] ifFalse: [child access]]
			ifNone: []].
	
	^ aMessage sendTo: element
]

{ #category : #'as yet unclassified' }
SBTSFieldAccessor >> element: aBlock [

	element := aBlock
]
