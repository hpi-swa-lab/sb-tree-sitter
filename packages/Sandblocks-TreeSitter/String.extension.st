Extension { #name : #String }

{ #category : #'*Sandblocks-TreeSitter' }
String >> parseTreeSitter: convert [
	<convert>

	convert
		if: [
			(convert objectInterface first isKindOf: SBTSObjectInterface)
				ifTrue: [ | parsed |
					parsed := convert objectInterface first slot language parseExpression: self.
					(parsed adaptSlotFor: convert objectInterface first slot ifFailed: [false]) ~~ false]
				ifFalse: [false]]
		do: [ | parsed |
			parsed := convert objectInterface first slot language parseExpression: self.
			parsed adaptSlotFor: convert objectInterface first slot ifFailed: [false]]
]

{ #category : #'*Sandblocks-TreeSitter' }
String >> sbSuggestionLimitedTo: aNumber maxLines: anotherNumber [
	
	| return |
	return := self.
	return size > aNumber ifTrue: [return := (return first: (aNumber - 3 clampLow: 1 high: return size)), '...'].
	return lines size > anotherNumber ifTrue: [return := ((return lines first: anotherNumber) joinSeparatedBy: String cr), '...'].
	^ return
]
