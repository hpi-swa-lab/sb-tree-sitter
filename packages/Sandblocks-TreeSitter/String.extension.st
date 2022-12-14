Extension { #name : #String }

{ #category : #'*Sandblocks-TreeSitter' }
String >> parseTreeSitter: convert [
	<convert>

	convert
		if: [convert objectInterface first = #isInlineBlock and: [convert objectInterface third factory class canParse: self]]
		do: [convert objectInterface third factory class parseElement: self]
]

{ #category : #'*Sandblocks-TreeSitter' }
String >> sbSuggestionLimitedTo: aNumber maxLines: anotherNumber [

	self size > aNumber ifTrue: [^ (self first: (aNumber - 3 clampLow: 1 high: self size)), '...'].
	self lines size > anotherNumber ifTrue: [^ ((self lines first: anotherNumber) joinSeparatedBy: String cr), '...'].
	^ self
]
