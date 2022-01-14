Class {
	#name : #SBTSParser,
	#superclass : #Object,
	#instVars : [
		'previousAlternatives',
		'stream',
		'memoizations'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #stream }
SBTSParser >> atEnd [

	^ stream atEnd
]

{ #category : #'as yet unclassified' }
SBTSParser >> incrementAlternativeFor: aNode [

	^ previousAlternatives at: aNode put: (self previousAlternativeFor: aNode) + 1
]

{ #category : #'initialize-release' }
SBTSParser >> initialize [

	super initialize.
	
	
]

{ #category : #memo }
SBTSParser >> memoizationFor: aString ifPresent: aSuccessBlock ifAbsentPut: aBlock [

	^ (memoizations at: stream position + 1)
		at: aString asSymbol
		ifPresent: aSuccessBlock
		ifAbsentPut: aBlock
]

{ #category : #stream }
SBTSParser >> next [

	^ stream next
]

{ #category : #query }
SBTSParser >> optionsFor: aNode given: aString before: aBoolean [

	self
		example: [SBTSParser new]
		args: [{SBTSSmalltalk instance bodyNodeForRule: 'primary'. '['. true}]
		label: 'example'.
	stream := aString readStream.
	^ aNode resultsFor: self
]

{ #category : #query }
SBTSParser >> optionsForTemplate: aNode given: aString [

	self
		example: [SBTSParser new]
		args: [{SBTSSmalltalk instance bodyNodeForRule: 'primary'. '['}]
		label: 'example'.
	stream := aString readStream.
	memoizations := (1 to: stream originalContents size) collect: [:i | IdentityDictionary new].
	^ aNode resultsFor: self
]

{ #category : #stream }
SBTSParser >> peek [

	^ stream peek
]

{ #category : #stream }
SBTSParser >> position [

	^ stream position
]

{ #category : #stream }
SBTSParser >> position: aNumber [

	stream position: aNumber
]

{ #category : #copying }
SBTSParser >> postCopy [

	super postCopy.
	stream := stream veryDeepCopy
]

{ #category : #'as yet unclassified' }
SBTSParser >> previousAlternativeFor: aNode [

	^ previousAlternatives at: aNode ifAbsent: [1]
]

{ #category : #stream }
SBTSParser >> stream [

	^ stream
]
