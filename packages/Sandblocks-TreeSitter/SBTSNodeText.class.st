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
SBTSNodeText >> copy [

	^ super copy
		regexString: self regexString;
		contents: self contents
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> currentTextMorph [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
SBTSNodeText >> initialize [

	super initialize.
	
	self addMorphBack: SBStringMorph new
]

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

{ #category : #'as yet unclassified' }
SBTSNodeText >> resultsFor: aParser [

	| start |
	" word-rule? "
	self flag: #todo.
	
	start := aParser position.
	^ (self regex matchesStreamPrefix: aParser stream)
		ifTrue: [
			{
				self copy
					contents: (aParser stream originalContents copyFrom: start + 1 to: aParser position);
					parser: aParser copy}]
		ifFalse: [
			aParser stream position: start.
			#noMatch]
]
