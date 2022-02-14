Class {
	#name : #SBTSFileParser,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #stream }
SBTSFileParser >> atEnd [

	^ stream atEnd
]

{ #category : #stream }
SBTSFileParser >> contentsSize [

	^ stream originalContents size
]

{ #category : #stream }
SBTSFileParser >> next [

	^ stream next
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> nodeForCursor: aCursor [

	aCursor isNamed ifFalse: [^ aCursor text].
	^ aCursor currentDo: [:type :node :template | | fields matches |
		fields := Array streamContents: [:s |
			aCursor gotoFirstChild ifTrue: [ | current |
				current := aCursor node.
				[s nextPut: (self nodeForCursor: aCursor)] doWhileFalse: [ | gap atEnd |
					atEnd := aCursor gotoNextSibling.
					(atEnd not and: [aCursor factory noteUncapturedText includes: type]) ifTrue: [
						gap := aCursor textBetween: current and: aCursor node.
						gap size > 0 ifTrue: [s nextPut: gap].
						current := aCursor node].
					atEnd].
				aCursor gotoParent]].
		stream := (fields ifEmpty: [aCursor text ifEmpty: [#()] ifNotEmpty: [{aCursor text}]]) readStream.
		matches := template takeNodesFrom: self.
		self assert: matches ~= #noMatch description: ('could not construct `{1}`' format: {type}).
		matches := matches select: [:match | match parser atEnd].
		self assert: matches size = 1.
		node addChild: matches first]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> parse: aString language: aFactory [

	| api |
	api := SBTreeSitter new.
	^ api parseAsCursor: aString language: aFactory class language do: [:cursor |
		self nodeForCursor: (SBTSCursor new library: api cursor: cursor factory: aFactory)]
]

{ #category : #stream }
SBTSFileParser >> peek [

	^ stream peek
]

{ #category : #stream }
SBTSFileParser >> position [

	^ stream position
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> postCopy [

	super postCopy.
	stream := (ReadStream on: stream contents)
		position: stream position;
		yourself
]
