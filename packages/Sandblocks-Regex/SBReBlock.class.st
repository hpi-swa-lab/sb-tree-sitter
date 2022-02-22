Class {
	#name : #SBReBlock,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReBlock class >> factory [

	^ SBRegex
]

{ #category : #'as yet unclassified' }
SBReBlock class >> type [

	^ nil
]

{ #category : #'as yet unclassified' }
SBReBlock >> initialize [

	super initialize.
	
	self
		factory: self class factory instance;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
SBReBlock >> sourceString [

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBReBlock >> writeSourceOn: aStream [

	aStream nextPutAll: self sourceString
]
