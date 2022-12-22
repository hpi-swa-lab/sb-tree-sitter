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

	| return |
	return := self.
	return size > aNumber ifTrue: [return := (return first: (aNumber - 3 clampLow: 1 high: return size)), '...'].
	return lines size > anotherNumber ifTrue: [return := ((return lines first: anotherNumber) joinSeparatedBy: String cr), '...'].
	^ return
]
