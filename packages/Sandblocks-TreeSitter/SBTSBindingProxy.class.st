Class {
	#name : #SBTSBindingProxy,
	#superclass : #Object,
	#instVars : [
		'getter',
		'setter'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSBindingProxy class >> getter: aBlock setter: anotherBlock [

	^ self new
		getter: aBlock setter: anotherBlock;
		yourself
]

{ #category : #'as yet unclassified' }
SBTSBindingProxy class >> trimQuotes: aBlock [

	^ SBTSBindingProxy
		getter: [aBlock contents allButFirst allButLast]
		setter: [:val | aBlock contents: ('"{1}"' format: [val])]
]

{ #category : #'as yet unclassified' }
SBTSBindingProxy >> contents [

	^ getter value
]

{ #category : #'as yet unclassified' }
SBTSBindingProxy >> contents: aString [

	setter value: aString
]

{ #category : #'as yet unclassified' }
SBTSBindingProxy >> getter: aBlock setter: anotherBlock [

	getter := aBlock.
	setter := anotherBlock
]
