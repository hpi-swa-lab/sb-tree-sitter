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
SBReVerboseComment class >> commentMarker [

	^ 'SBReVerboseComment:'
]

{ #category : #'as yet unclassified' }
SBReVerboseComment class >> isEncodedComment: aString [

	^ aString beginsWith: self commentMarker
]

{ #category : #'as yet unclassified' }
SBReVerboseComment class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(non_capturing_group
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
) @comment'
	sample: '(?:(?:comment){0}(?:pattern))'>

	| text |
	
	text := (aDictionary at: 'text') sourceString.
	(self isEncodedComment: text) ifFalse: [^ nil].

	^ aBlock value: (aDictionary at: 'comment') value: (self new
		pattern: (aDictionary at: 'pattern');
		encodedComment: text)
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
SBReVerboseComment >> encodedComment [

	^ self class commentMarker, self comment base64Encoded
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> encodedComment: aString [

	self assert: [self class isEncodedComment: aString].
	self comment: (aString from: self class commentMarker size + 1) base64Decoded
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBTSUnknown new
			factory: self factory;
			template: (self factory getTemplate: 'pattern'));
		addMorphBack: (comment := SBTextBubble multiLine
			placeholderText: 'comment')
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> pattern [

	^ self submorphs first
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> pattern: aBlock [

	self submorphs first replaceBy: aBlock buildCopy
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> sourceString [

	^ '(?:(?:',
		self encodedComment,
		')',
		'{0}',
		'(?:',
		self pattern sourceString,
		'))'
]

{ #category : #'as yet unclassified' }
SBReVerboseComment >> type [

	^ 'non_capturing_group'
]
