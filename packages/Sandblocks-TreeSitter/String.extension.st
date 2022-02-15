Extension { #name : #String }

{ #category : #'*Sandblocks-TreeSitter' }
String >> parseTreeSitter: convert [
	<convert>

	convert
		if: [convert objectInterface first = #isInlineBlock and: [convert objectInterface third factory class canParse: self]]
		do: [convert objectInterface third factory class parseElement: self]
]
