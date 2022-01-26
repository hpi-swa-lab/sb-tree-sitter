Class {
	#name : #SBTSNodeText,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'regexString',
		'regex'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #copying }
SBTSNodeText >> basicCopy [

	^ super basicCopy
		regexString: self regexString;
		contents: self contents
]

{ #category : #copying }
SBTSNodeText >> copy [

	self assert: self isConcrete.
	^ self basicCopy contents: self contents
]

{ #category : #accessing }
SBTSNodeText >> currentTextMorph [

	^ self firstSubmorph
]

{ #category : #initialization }
SBTSNodeText >> initialize [

	super initialize.
	
	self addMorphBack: SBStringMorph new
]

{ #category : #accessing }
SBTSNodeText >> maxChildren [

	^ 0
]

{ #category : #printing }
SBTSNodeText >> printOn: aStream [

	aStream nextPut: $/.
	aStream nextPutAll: self regexString.
	aStream nextPut: $/
]

{ #category : #accessing }
SBTSNodeText >> regex [

	^ regex
]

{ #category : #accessing }
SBTSNodeText >> regexString [

	^ regexString
]

{ #category : #accessing }
SBTSNodeText >> regexString: aString [

	regexString := aString.
	regex := aString asRegex
]

{ #category : #parsing }
SBTSNodeText >> resultsFor: aParser [

	| start |
	" word-rule? "
	self flag: #todo.
	
	start := aParser position.
	^ (self regex matchesStreamPrefix: aParser stream)
		ifTrue: [
			{
				self makeConcrete
					contents: (aParser stream originalContents copyFrom: start + 1 to: aParser position);
					parser: aParser copy}]
		ifFalse: [
			aParser stream position: start.
			#noMatch]
]
