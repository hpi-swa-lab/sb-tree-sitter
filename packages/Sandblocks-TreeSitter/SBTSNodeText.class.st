Class {
	#name : #SBTSNodeText,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'regexString',
		'regex'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeText >> printOn: aStream [

	aStream nextPut: $/.
	aStream nextPutAll: self regexString.
	aStream nextPut: $/
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> regex [

	^ regex
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> regexString [

	^ regexString
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> regexString: aString [

	regexString := aString.
	regex := aString asRegex
]
