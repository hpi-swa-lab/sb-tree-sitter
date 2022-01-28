Class {
	#name : #SBReCommentPlacer,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReCommentPlacer class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(term) @term'>
	
	^ nil
"	^ aBlock
		value: (aDictionary at: 'term')
		value: (self new block: (aDictionary at: 'term'))"
]

{ #category : #'as yet unclassified' }
SBReCommentPlacer >> block: aBlock [

	self addMorphBack: (SBRow new
			addMorphBack: (SBInlineBlockSymbol new addMorphBack: aBlock buildCopy);
			addMorphBack: (SBTextBubble new placeholderText: 'comment'))
]

{ #category : #'as yet unclassified' }
SBReCommentPlacer >> content [

	^ self submorphs first submorphs first
]

{ #category : #'as yet unclassified' }
SBReCommentPlacer >> type [

	^ self content type
]

{ #category : #'as yet unclassified' }
SBReCommentPlacer >> writeSourceOn: aStream [

	self content writeSourceOn: aStream
]
