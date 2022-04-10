Class {
	#name : #SBTSBinding,
	#superclass : #Object,
	#instVars : [
		'from',
		'to',
		'selector'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSBinding >> from [

	^ from
]

{ #category : #'as yet unclassified' }
SBTSBinding >> from: aBlock to: anotherBlock [

	from := aBlock.
	to := anotherBlock
]

{ #category : #'as yet unclassified' }
SBTSBinding >> initialize [

	super initialize.
	
	selector := #contents
]

{ #category : #'as yet unclassified' }
SBTSBinding >> selector: aSymbol [

	selector := aSymbol
]

{ #category : #'as yet unclassified' }
SBTSBinding >> to [

	^ to
]

{ #category : #'as yet unclassified' }
SBTSBinding >> update [

	from perform: selector with: (to perform: selector)
]
