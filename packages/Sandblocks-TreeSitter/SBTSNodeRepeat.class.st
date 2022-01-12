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

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> multiple [

	^ multiple
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> multiple: aBoolean required: anotherBoolean element: aMorph [

	multiple := aBoolean.
	required := anotherBoolean.
	element := aMorph
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> printOn: aStream [

	element printOn: aStream.
	(multiple and: [required]) ifTrue: [^ aStream nextPut: $+].
	(multiple and: [required not]) ifTrue: [^ aStream nextPut: $*].
	aStream nextPut: $?
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> required [

	^ required
]
