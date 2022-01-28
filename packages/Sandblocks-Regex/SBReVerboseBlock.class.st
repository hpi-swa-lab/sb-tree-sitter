Class {
	#name : #SBReVerboseBlock,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseBlock class >> factory [

	^ SBRegex instance
]

{ #category : #'as yet unclassified' }
SBReVerboseBlock >> initialize [

	super initialize.
	
	self
		factory: self class factory;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap
]
