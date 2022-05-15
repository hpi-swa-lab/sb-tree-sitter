Extension { #name : #String }

{ #category : #'*Sandblocks-Clojure' }
String >> bencodeOn: aStream [

	aStream print: self size.
	aStream nextPut: $:.
	aStream nextPutAll: self
]
