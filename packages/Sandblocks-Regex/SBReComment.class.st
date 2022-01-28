Class {
	#name : #SBReComment,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'content'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReComment >> initialize [

	self addMorphBack: (SBTextBubble new placeholderText: 'comment')
]

{ #category : #'as yet unclassified' }
SBReComment >> type [

	^ 'non_capturing_group'
]

{ #category : #'as yet unclassified' }
SBReComment >> writeSourceOn: aStream [

	aStream nextPutAll: '(?:...)'
]
