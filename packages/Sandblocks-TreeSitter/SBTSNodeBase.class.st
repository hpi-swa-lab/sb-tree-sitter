Class {
	#name : #SBTSNodeBase,
	#superclass : #Object,
	#instVars : [
		'field',
		'factory',
		'parent'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #blocks }
SBTSNodeBase >> allChildrenDo: aBlock [

	self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> allSuperTypesDo: aBlock [

	self parent ifNotNil: [:o | o allSuperTypesDo: aBlock]
]

{ #category : #hierarchy }
SBTSNodeBase >> andParentsDo: aBlock [

	| current |
	current := self.
	[aBlock value: current] doWhileTrue: [(current := current parent) notNil]
]

{ #category : #blocks }
SBTSNodeBase >> buildEmpty [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> buildMorphWith: aBlock slot: aSlot [

	(self factory promotedInlineSymbols includes: self type) ifTrue: [
		self assert: aBlock isString.
		^ SBTSTextMorph new contents: aBlock].
	^ aBlock slot: aSlot
]

{ #category : #testing }
SBTSNodeBase >> compatibleWithType: aSymbol [

	^ factory type: self type compatibleWith: aSymbol
]

{ #category : #blocks }
SBTSNodeBase >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> factory [

	^ factory
]

{ #category : #accessing }
SBTSNodeBase >> factory: aFactory [

	factory := aFactory
]

{ #category : #accessing }
SBTSNodeBase >> field [

	^ field
]

{ #category : #accessing }
SBTSNodeBase >> field: aString [

	field := aString
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> hasParent: aNode [

	self andParentsDo: [:p | p = aNode ifTrue: [^ true]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> hasParentThat: aBlock [

	self andParentsDo: [:p | (aBlock value: p) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSLabel [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSNode [

	^ true
]

{ #category : #testing }
SBTSNodeBase >> isTSOptional [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSRepeat [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSeq [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSymbol [

	^ false
]

{ #category : #accessing }
SBTSNodeBase >> language [

	^ self factory name
]

{ #category : #accessing }
SBTSNodeBase >> parent [

	^ parent
]

{ #category : #accessing }
SBTSNodeBase >> parent: aNode [

	parent := aNode
]

{ #category : #printing }
SBTSNodeBase >> printElementsSeparated: aCollection on: aStream indent: aNumber [

	| first delimiter lastMatchedWordRule suffixMatchesWordRule lastString |
	first := true.
	lastMatchedWordRule := false.
	lastString := ''.
	delimiter := (self containingSymbol ifNotNil: #type)
		ifNotNil: [:parentType |
			self factory delimitedRules
				at: parentType
				ifPresent: [:delim | delim first]
				ifAbsent: ['']]
		ifNil: [''].
	suffixMatchesWordRule := [:string | (factory notNil and: [factory separatorRule notNil]) and: [(1 to: string size) anySatisfy: [:start | factory separatorRule matchesStream: (string readStream position: start - 1)]]].
	aCollection withIndexDo: [:element :index | | string |
		string := String streamContents: [:stream |
			element writeSourceOn: stream indent: ((self factory indentMatch: element)
				ifTrue: [aNumber + 1]
				ifFalse: [aNumber])].
		self isTSRepeat
			ifTrue: [
				first ifFalse: [aStream nextPutAll: delimiter].
				((index > 1 and: [(self factory hardLineBreakMatchBetween: (aCollection at: index - 1) and: element) or: [(self containingSymbol ifNotNil: #isStatementContainer ifNil: [false]) and: [(self containingSymbol parentSandblock satisfies: #(#notNil #isTSNode)) or: [first not]]]]) and: [string notEmpty]) ifTrue: [aStream crtab: aNumber]]
			ifFalse: [
				(self isTSSeq and: [index > 1 and: [self factory hardLineBreakMatchBetween: (aCollection at: index - 1) and: element]])
					ifTrue: [
						aStream crtab: ((self factory indentMatch: element)
							ifTrue: [aNumber + 1]
							ifFalse: [aNumber])]
					ifFalse: [(string notEmpty and: [lastMatchedWordRule and: [suffixMatchesWordRule value: lastString, string first]]) ifTrue: [aStream space]]].
		string ifNotEmpty: [
			lastMatchedWordRule := suffixMatchesWordRule value: string.
			lastString := string.
			aStream nextPutAll: string].
		first := false]
]

{ #category : #parsing }
SBTSNodeBase >> resultsFor: aParser [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> root [

	^ self parent ifNil: [self] ifNotNil: [:p | p root]
]

{ #category : #parsing }
SBTSNodeBase >> takeNodesFrom: aParser [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> type [

	^ nil
]
