"
SBReBlock is the superclass for all custom replacements for regular expressions in Sandblocks.

It just contains some utility for the subclasses.
"
Class {
	#name : #SBReBlock,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Regex'
}

{ #category : #accessing }
SBReBlock class >> factory [

	^ SBRegex
]

{ #category : #initialization }
SBReBlock >> initialize [

	super initialize.
	
	self
		factory: self class factory instance;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap
]

{ #category : #printing }
SBReBlock >> sourceString [

	self subclassResponsibility
]

{ #category : #printing }
SBReBlock >> writeSourceOn: aStream [

	aStream nextPutAll: self sourceString
]
