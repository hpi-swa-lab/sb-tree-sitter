Extension { #name : #SequenceableCollection }

{ #category : #'*DomainCode-Core' }
SequenceableCollection >> overlappingPairsLoopedDo: aBlock [
	"Emit overlapping pairs of my elements into aBlock"

	1 to: self size - 1 do: [:i | aBlock value: (self at: i) value: (self at: i + 1)].
	self size >= 2 ifTrue: [aBlock value: self last value: self first]
]
