"
A SBReAnnotation is a replacement that can persist an annotation in the source code of the regex.

An annotation always refers to a sub-pattern of the regex and is a non-capturing group (see SBRePatternWrapper).

The annotation is persisted in the following form:

	(?(?:marker annotation){0}(?:pattern))

For example:

	(?:(?:SBReComment:aGV4YWRlY2ltYWwgbnVtYmVy){0}(?:0x[0-9a-f]))
	
where marker = 'SBReComment:', annotation = 'aGV4YWRlY2ltYWwgbnVtYmVy' and pattern = '0x[0-9a-f]'.

'marker' identifies the concrete type of annotation and 'annotation' is the concrete annotation. The annotation needs to be encoded in a way that it does not represent invalid syntax. For now, this used base64 encoding. The marker and annotation are ignored using the '{0}'. After that, the pattern the annotation is associated with, is also included in a non-capturing group. Non-capturing groups are used to not add any additional groups that show up in the match result.
"
Class {
	#name : #SBReAnnotation,
	#superclass : #SBRePatternWrapper,
	#category : #'Sandblocks-Regex'
}

{ #category : #helpers }
SBReAnnotation class >> classForAnnotation: aString [

	| class |

	class := self subclasses select: [:each | aString beginsWith: each marker].
	self assert: class size < 2 description: 'annotation class not uniquely identified'.
	^ class size = 1 ifTrue: [class first] ifFalse: [nil]
]

{ #category : #accessing }
SBReAnnotation class >> marker [

	^ self asString, ':'
]

{ #category : #matchers }
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
	class := (self classForAnnotation: annotation) ifNil: [^ nil].

	^ aBlock
		value: (aDictionary at: 'block')
		value: (class new
			pattern: (aDictionary at: 'pattern');
			encodedAnnotation: annotation)
]

{ #category : #accessing }
SBReAnnotation >> annotation [

	self subclassResponsibility
]

{ #category : #accessing }
SBReAnnotation >> annotation: aString [

	self subclassResponsibility
]

{ #category : #accessing }
SBReAnnotation >> encodedAnnotation [

	^ self class marker, self annotation base64Encoded
]

{ #category : #accessing }
SBReAnnotation >> encodedAnnotation: aString [

	self annotation: (aString from: self class marker size + 1) base64Decoded
]

{ #category : #printing }
SBReAnnotation >> sourceString [

	^ '(?:(?:{1})\{0\}(?:{2}))'
		format: {self encodedAnnotation . self pattern sourceString}
]
