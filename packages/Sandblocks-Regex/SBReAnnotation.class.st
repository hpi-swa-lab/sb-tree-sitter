Class {
	#name : #SBReAnnotation,
	#superclass : #SBRePatternWrapper,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReAnnotation class >> annotationClass: aString [

	| class |

	class := self subclasses select: [:each | aString beginsWith: each marker].
	self assert: class size < 2 description: 'annotation class not uniquely identified'.
	^ class size = 1 ifTrue: [class first] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBReAnnotation class >> marker [

	^ self asString, ':'
]

{ #category : #'as yet unclassified' }
SBReAnnotation class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(non_capturing_group
	(pattern
		(term
			(non_capturing_group
				(pattern) @annotation
			)
			(count_quantifier) @zero
			(non_capturing_group
				(pattern) @pattern
			)
		)
	)
) @block'
	sample: '(?:(?annotation){0}(?:pattern))'>

	| annotation class |

	annotation := (aDictionary at: 'annotation') sourceString.
	class := (self annotationClass: annotation) ifNil: [^ nil].

	^ aBlock
		value: (aDictionary at: 'block')
		value: (class new
			pattern: (aDictionary at: 'pattern');
			encodedAnnotation: annotation)
]

{ #category : #'as yet unclassified' }
SBReAnnotation >> annotation [

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBReAnnotation >> annotation: aString [

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBReAnnotation >> encodedAnnotation [

	^ self class marker, self annotation base64Encoded
]

{ #category : #'as yet unclassified' }
SBReAnnotation >> encodedAnnotation: aString [

	self annotation: (aString from: self class marker size + 1) base64Decoded
]

{ #category : #'as yet unclassified' }
SBReAnnotation >> sourceString [

	^ '(?:(?:{1})\{0\}(?:{2}))'
		format: {self encodedAnnotation . self pattern sourceString}
]
