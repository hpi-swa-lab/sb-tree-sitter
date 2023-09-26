Extension { #name : #String }

{ #category : #'*DomainCode-Diff' }
String >> levenshteinDistanceTo: anotherString [

	| stab cost |
	"if a string is empty, answer the length of the another string"
	"code taken from Olivier Auverlot's Phonetix package"
	self size = 0 ifTrue: ["return the Levenshtein distance between two strings"
	^ anotherString size].
	anotherString size = 0 ifTrue: [^ self size].
	stab := Matrix rows: anotherString size + 1 columns: self size + 1.
	1 to: stab columnCount do: [:i | stab at: 1 at: i put: i - 1].
	1 to: stab rowCount do: [:i | stab at: i at: 1 put: i - 1].
	2 to: stab columnCount do: [:i |
		2 to: stab rowCount do: [:j |
			(self at: i - 1) = (anotherString at: j - 1)
				ifTrue: [cost := 0]
				ifFalse: [cost := 1].
			stab
				at: j
				at: i
				put: ({(stab at: j at: i - 1) + 1. (stab at: j - 1 at: i) + 1. (stab at: j - 1 at: i - 1) + cost} asSortedCollection: [:a :b | a < b]) first]].
	^ stab at: stab rowCount at: stab columnCount
]

{ #category : #'*DomainCode-Diff' }
String >> levenshteinRatioTo: anotherString [

	| lengthSum |
	lengthSum := self size + anotherString size.
	^ (lengthSum - (self levenshteinDistanceTo: anotherString) / lengthSum) asFloat
]
