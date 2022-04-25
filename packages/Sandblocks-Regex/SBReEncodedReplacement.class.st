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
	#name : #SBReEncodedReplacement,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #helpers }
SBReEncodedReplacement class >> newAround: aBlock [

	| regex command |
	regex := (SBTSFileParser new
		parse: ('(?:(?:{1}:)\{0\}(?:x))' format: {self name})
		language: SBRegex) childSandblocks first childSandblocks first.
	command := SBCombinedCommand newWith: (aBlock owner ifNotNil: {SBReplaceCommand new target: aBlock replacer: regex} ifNil: [{}]), {SBReplaceCommand new target: regex lastDeepChild replacer: aBlock. regex applyReplacementCommand}.
	^ aBlock sandblockEditor
		ifNotNil: [aBlock sandblockEditor do: command]
		ifNil: [command do]
]

{ #category : #helpers }
SBReEncodedReplacement class >> subclassForAnnotation: aString [

	| classes |
	classes := self allSubclasses select: [:each | aString beginsWith: each name].
	self assert: classes size < 2 description: 'annotation class not uniquely identified'.
	^ classes ifNotEmpty: [classes first] ifEmpty: [nil]
]

{ #category : #'as yet unclassified' }
SBReEncodedReplacement >> build [
	<lang: #regex match: '(non_capturing_group
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
) @block' sample: '(?:(?:annotation){0}(?:pattern))'>

	^ (self class subclassForAnnotation: (bindings at: 'annotation') sourceString) ifNotNil: [:class |
		class new
			bindings: bindings block: (bindings at: 'root');
			build]
]

{ #category : #'as yet unclassified' }
SBReEncodedReplacement >> createBindingFor: aString build: aClosure update: anUpdateClosure [

	^ self
		createBinding: [:c | aClosure value: ((c at: aString) sourceString from: self className size + 2) base64Decoded]
		update: [:c :m | | new |
			new := SBTSFileParser new
				parse: self className, ':', (anUpdateClosure value: c value: m) base64Encoded
				language: SBRegex.
			(c at: aString) replaceBy: new.
			c at: aString put: new]
]

{ #category : #'as yet unclassified' }
SBReEncodedReplacement >> createBindingListFor: aString build: aClosure update: anUpdateClosure [

	^ self
		createBinding: [:c | aClosure value: ((((c at: aString) sourceString from: self className size + 2) splitBy: ',') collect: #base64Decoded)]
		update: [:c :m | | new |
			new := SBTSFileParser new
				parse: self className, ':', (((anUpdateClosure value: c value: m) collect: #base64Encoded) joinSeparatedBy: ',')
				language: SBRegex.
			(c at: aString) replaceBy: new.
			c at: aString put: new]
]
