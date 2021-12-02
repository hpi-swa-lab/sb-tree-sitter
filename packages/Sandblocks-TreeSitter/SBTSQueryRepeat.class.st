Class {
	#name : #SBTSQueryRepeat,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'type',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> element: anObject [

	element := anObject
]

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> evaluateAgainst: aBlock captures: aDictionary [

	^ self element evaluateAgainst: aBlock captures: aDictionary
]

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> isOptional [

	^ self type = $?
]

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> predicatesOn: stream [

	self element predicatesOn: stream
]

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> requiresField [

	^ self element requiresField
]

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> type [

	^ type
]

{ #category : #'as yet unclassified' }
SBTSQueryRepeat >> type: aCharacter [

	type := aCharacter
]
