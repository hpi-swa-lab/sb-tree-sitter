Extension { #name : #SequenceableCollection }

{ #category : #'*Sandblocks-Clojure' }
SequenceableCollection >> bencodeOn: aStream [

	aStream nextPut: $l.
	self do: [:value | value bencodeOn: aStream].
	aStream nextPut: $e
]
