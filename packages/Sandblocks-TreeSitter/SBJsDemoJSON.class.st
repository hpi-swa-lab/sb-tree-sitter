Class {
	#name : #SBJsDemoJSON,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-TreeSitter-Examples'
}

{ #category : #'as yet unclassified' }
SBJsDemoJSON class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(pair key: (identifier) ="headers" (object) @headers)' sample: '{headers: {"A": "b", "d-a": "asd", C: "d"}}'>

	true ifTrue: [^ nil].
	^ aBlock
		value: (aDictionary at: 'headers')
		value: (self new pairs: (aDictionary at: 'headers') access children)
]

{ #category : #'as yet unclassified' }
SBJsDemoJSON >> pairs [
	| map |
	map := Dictionary new.
	(1 to: self childSandblocks size) do: [:n| | key value |
		key := (self childSandblocks at: n) childSandblocks first childSandblocks first contents.
		value := (self childSandblocks at: n) childSandblocks second childSandblocks first contents.
		map at: key put: value].
	^map
]

{ #category : #'as yet unclassified' }
SBJsDemoJSON >> pairs: aCollection [

	self
		changeTableLayout;
		listDirection: #topToBottom;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		layoutInset: 6.
	
	aCollection do: [:pair | self addMorphBack: pair buildCopy]
]

{ #category : #'as yet unclassified' }
SBJsDemoJSON >> writeSourceOn: aStream [

	aStream nextPut: ${.
	self childSandblocksDo: [:pair |
		pair writeSourceOn: aStream.
		aStream nextPut: $,].
	aStream nextPut: $}
]
