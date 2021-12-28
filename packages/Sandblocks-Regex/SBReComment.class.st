Class {
	#name : #SBReComment,
	#superclass : #SBInlineBlockSymbol,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReComment >> block [

	^ self submorphs first submorphs first
]

{ #category : #'as yet unclassified' }
SBReComment >> block: aBlock [

	self addMorphBack: (SBRow new
			addMorphBack: (SBInlineBlockSymbol new addMorphBack: aBlock buildCopy);
			addMorphBack: (SBTextBubble new placeholderText: 'comment'))
]

{ #category : #'as yet unclassified' }
SBReComment >> type [

	^ self block type
]
