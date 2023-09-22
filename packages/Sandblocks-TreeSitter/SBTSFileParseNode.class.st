Class {
	#name : #SBTSFileParseNode,
	#superclass : #SBTSParseNode,
	#instVars : [
		'range'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #'as yet unclassified' }
SBTSFileParseNode >> range [

	^ range ifNil: [super range]
]

{ #category : #'as yet unclassified' }
SBTSFileParseNode >> range: aRange [

	range := aRange
]
