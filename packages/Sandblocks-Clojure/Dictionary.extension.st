Extension { #name : #Dictionary }

{ #category : #'*Sandblocks-Clojure' }
Dictionary >> bencodeOn: aStream [

	aStream nextPut: $d.
	self withKeysSortedSafely keysAndValuesDo: [:key :value |
		self assert: key isString.
		key bencodeOn: aStream.
		value bencodeOn: aStream].
	aStream nextPut: $e
]
