Class {
	#name : #SBReNonCapturingGroup,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReNonCapturingGroup class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(non_capturing_group
	(pattern 
		(term)
	@pattern)
) @group'>

	^ nil
	"^ aBlock
		value: (aDictionary at: 'group')
		value: (self new pattern: (aDictionary at: 'group'))
"
]

{ #category : #'as yet unclassified' }
SBReNonCapturingGroup >> pattern: aBlock [

	self addMorphBack: (SBRow new
			addMorphBack: aBlock buildCopy;
			addMorphBack: (SBTextBubble new placeholderText: 'comment'))
]

{ #category : #'as yet unclassified' }
SBReNonCapturingGroup >> type [

	^ 'non_capturing_group'
]

{ #category : #'as yet unclassified' }
SBReNonCapturingGroup >> writeSourceOn: aStream [

	aStream nextPutAll: '(?:...)'
]
