Extension { #name : #Integer }

{ #category : #'*Sandblocks-Clojure' }
Integer >> bencodeOn: aStream [

	aStream nextPut: $i.
	aStream print: self.
	aStream nextPut: $e
]
