Class {
	#name : #SBReVerboseComment,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'pattern',
		'comment'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseComment class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match: '(non_capturing_group
	(pattern
		(term
			(non_capturing_group
				(pattern) @text
			)
			(count_quantifier) @zero
			(non_capturing_group
				(pattern) @pattern
			)
		)
	)
) @comment' sample: '(?:(?:kommentar){0}(?:pattern))'>

	^ aBlock value: (aDictionary at: 'comment') value: (self new
		pattern: (aDictionary at: 'pattern');
		name: (aDictionary at: 'name') submorphs first contents)
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> absorbsInput: anEvent [

	^ SBGrammarHandler eventValidForString: anEvent
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> comment [

	^ comment contents
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> comment: aString [

	comment contents: aString
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> commentMarker [

	^ 'SBReVerboseComment:'
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> initialize [

	super initialize.
	
	self
		addMorphBack: (pattern := SBTSUnknown new
			factory: self factory;
			template: (self factory getTemplate: 'pattern'));
		addMorphBack: (comment := SBTextBubble multiLine
			placeholderText: 'comment')
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> pattern [

	^ pattern
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> pattern: aBlock [

	pattern := aBlock
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> sourceString [

	^ '(?:(?:',
		self comment,
		'){0}',
		self pattern sourceString,
		')'
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> type [

	^ 'non_capturing_group'
]
