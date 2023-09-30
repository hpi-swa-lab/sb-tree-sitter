Extension { #name : #String }

{ #category : #'*DomainCode-Diff' }
String >> levenshteinDistanceTo: anotherString [

	| stab cost |
	"consider https://docs.python.org/3/library/difflib.html"
	self size = 0 ifTrue: [^ anotherString size].
	anotherString size = 0 ifTrue: [^ self size].
	
	stab := Matrix rows: anotherString size + 1 columns: self size + 1.
	1 to: stab columnCount do: [:i | stab atFast: 1 at: i put: i - 1].
	1 to: stab rowCount do: [:i | stab atFast: i at: 1 put: i - 1].
	2 to: stab columnCount do: [:i |
		2 to: stab rowCount do: [:j |
			(self at: i - 1) = (anotherString at: j - 1)
				ifTrue: [cost := 0]
				ifFalse: [cost := 1].
			stab
				atFast: j
				at: i
				put: (((stab atFast: j at: i - 1) + 1 min: (stab atFast: j - 1 at: i - 1) + cost) min: (stab atFast: j - 1 at: i) + 1)]].
	^ stab atFast: stab rowCount at: stab columnCount
]

{ #category : #'*DomainCode-Diff' }
String >> levenshteinRatioTo: anotherString [

	| lengthSum |
	lengthSum := self size + anotherString size.
	^ (lengthSum - (self levenshteinDistanceTo: anotherString) / lengthSum) asFloat
]
