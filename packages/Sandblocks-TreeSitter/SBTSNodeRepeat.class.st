Class {
	#name : #SBTSNodeRepeat,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'multiple',
		'required',
		'element'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> allChildrenDo: aBlock [

	aBlock value: self.
	self element allChildrenDo: aBlock
]

{ #category : #copying }
SBTSNodeRepeat >> basicCopy [

	^ super basicCopy multiple: self multiple required: self required element: self element
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> buildEmpty [

	^ self required ifTrue: [self element buildEmpty] ifFalse: [{}]
]

{ #category : #query }
SBTSNodeRepeat >> childrenForQueryDo: aBlock [

	self submorphsDo: [:m | m childrenForQueryDo: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aCollection parent: aBlock [

	| buildInsert hasElements |
	buildInsert := [:index :before |
		aClosure value: (SBCursorInsert new
			command: (SBTSNodeInsertCommand new element: element container: aBlock index: index);
			before: before;
			adjacent: nil;
			container: aBlock)].
	
	hasElements := false.
	multiple ifTrue: [buildInsert value: (self firstInsertIndexIn: aBlock) value: false].
	aCollection doWithIndex: [:block :index |
		(block slot includesParent: self) ifTrue: [
			hasElements := true.
			block cursorPositionsDo: aClosure.
			multiple ifTrue: [buildInsert value: index + 1 value: true]]].
	(multiple not and: [hasElements not]) ifTrue: [buildInsert value: (self firstInsertIndexIn: aBlock) value: true]
]

{ #category : #accessing }
SBTSNodeRepeat >> element [

	^ element
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> firstInsertIndexIn: aParent [

	| stream seen |
	seen := false.
	stream := aParent submorphs readStream.
	aParent slot firstNode bodyTemplate allChildrenDo: [:child |
		(seen not and: [stream atEnd not and: [child = stream peek slot firstNode]]) ifTrue: [stream next].
		child = element ifTrue: [^ stream position + 1]].
	^ 1
]

{ #category : #testing }
SBTSNodeRepeat >> isTSRepeat [

	^ true
]

{ #category : #layout }
SBTSNodeRepeat >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (Array streamContents: [:stream |
			self submorphs withIndexDo: [:morph :index |
				stream nextPut: morph layoutCommands.
				index ~= self submorphCount ifTrue: [
					stream nextPut: (((self factory hardLineBreakMatcher value: morph) or: [self containingSymbol isStatementContainer])
						ifTrue: [SBAlgebraCommand hardLine withGap: true]
						ifFalse: [SBAlgebraCommand softLineOrGap withGap: true])]]])
]

{ #category : #accessing }
SBTSNodeRepeat >> maxChildren [

	^ self multiple ifTrue: [900000000] ifFalse: [1]
]

{ #category : #accessing }
SBTSNodeRepeat >> multiple [

	^ multiple
]

{ #category : #accessing }
SBTSNodeRepeat >> multiple: aBoolean required: anotherBoolean element: aMorph [

	multiple := aBoolean.
	required := anotherBoolean.
	element := aMorph.
	
	element parent: self
]

{ #category : #printing }
SBTSNodeRepeat >> printOn: aStream [

	element printOn: aStream.
	(multiple and: [required]) ifTrue: [^ aStream nextPut: $+].
	(multiple and: [required not]) ifTrue: [^ aStream nextPut: $*].
	aStream nextPut: $?
]

{ #category : #accessing }
SBTSNodeRepeat >> required [

	^ required
]

{ #category : #parsing }
SBTSNodeRepeat >> resultsFor: aParser [

	| results |
	results := self element resultsFor: aParser.
	results = #noMatch ifTrue: [^ self required ifTrue: [#noMatch] ifFalse: [{self makeConcrete parser: aParser}]].
	^ results collect: [:result | self makeConcrete addChild: result]
]

{ #category : #parsing }
SBTSNodeRepeat >> takeNodesFrom: aParser [

	| queue |
	queue := OrderedCollection with: {aParser. 0}.
	^ (Array streamContents: [:stream |
		[queue notEmpty] whileTrue: [ | pair results parser currentPosition index |
			pair := queue removeFirst.
			parser := pair first copy.
			index := pair second + 1.
			currentPosition := parser position.
			results := self element takeNodesFrom: parser.
			results ~= #noMatch ifTrue: [
				results do: [:candidate |
					"to fix troubles with infinitely repeating matches, we only accept results
if they advanced the parser."
					candidate position > currentPosition ifTrue: [
						stream nextPut: candidate.
						queue add: {candidate. index}]]]]]) ifEmpty: [self required ifTrue: [#noMatch] ifFalse: [{aParser copy}]]
]

{ #category : #printing }
SBTSNodeRepeat >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
