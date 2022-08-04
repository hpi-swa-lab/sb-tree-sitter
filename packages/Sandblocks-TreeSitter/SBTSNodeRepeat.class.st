Class {
	#name : #SBTSNodeRepeat,
	#superclass : #SBTSNodeBase,
	#instVars : [
		'multiple',
		'required',
		'element',
		'delimiter',
		'isStatementRepeater'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #blocks }
SBTSNodeRepeat >> allChildrenDo: aBlock visited: aSet [

	aBlock value: self.
	self element allChildrenDo: aBlock visited: aSet
]

{ #category : #blocks }
SBTSNodeRepeat >> allElementsDo: aBlock [

	aBlock value: self.
	self element allElementsDo: aBlock
]

{ #category : #testing }
SBTSNodeRepeat >> allSubTypesDo: aBlock parents: aCollection [

	self element allSubTypesDo: aBlock parents: aCollection
]

{ #category : #blocks }
SBTSNodeRepeat >> buildEmpty [

	^ self required ifTrue: [self element buildEmpty] ifFalse: [{}]
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> buildEmptyNodes [

	^ self required ifTrue: [self element buildEmptyNodes] ifFalse: [{}]
]

{ #category : #hierarchy }
SBTSNodeRepeat >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	| buildInsert hasElements |
	buildInsert := [:index :before |
		aClosure value: (SBCursorInsert new
			command: (SBTSNodeInsertCommand new element: element container: aBlock index: index);
			before: before;
			adjacent: nil;
			container: aBlock)].
	
	hasElements := false.
	multiple ifTrue: [buildInsert value: aStream position + 1 value: false].
	
	[aStream atEnd not and: [aStream peek slot includesParent: self]] whileTrue: [ | currentPos |
		currentPos := aStream position.
		hasElements := true.
		element cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock.
		multiple ifTrue: [buildInsert value: aStream position + 1 value: true].
		self assert: aStream position > currentPos].
	
	(multiple not and: [hasElements not]) ifTrue: [buildInsert value: aStream position + 1 value: true]
]

{ #category : #accessing }
SBTSNodeRepeat >> delimiter [

	^ delimiter
]

{ #category : #accessing }
SBTSNodeRepeat >> delimiter: aString [

	delimiter := aString
]

{ #category : #accessing }
SBTSNodeRepeat >> element [

	^ element
]

{ #category : #accessing }
SBTSNodeRepeat >> element: aNode [

	element := aNode.
	aNode parent: self
]

{ #category : #hierarchy }
SBTSNodeRepeat >> groupsIn: aContainerBlock [

	| candidates |
	^ Array streamContents: [:stream | | stop |
		candidates := (aContainerBlock submorphs select: [:m | m slot includesParent: self]) readStream.
		stop := false.
		[candidates atEnd not and: [stop not]] whileTrue: [
			(Array streamContents: [:groupStream | element traverseBlocks: candidates do: [:block | groupStream nextPut: block]])
				ifNotEmpty: [:group | stream nextPut: group]
				ifEmpty: [stop := true]]]
]

{ #category : #testing }
SBTSNodeRepeat >> hasEqualStructure: aNode [

	^ (super hasEqualStructure: aNode) and: [aNode required = self required and: [self multiple = aNode multiple]]
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> initialize [

	super initialize.
	
	isStatementRepeater := false
]

{ #category : #accessing }
SBTSNodeRepeat >> isStatementRepeater [

	^ isStatementRepeater
]

{ #category : #accessing }
SBTSNodeRepeat >> isStatementRepeater: aBoolean [

	isStatementRepeater := aBoolean
]

{ #category : #testing }
SBTSNodeRepeat >> isTSOptional [

	^ self required not and: [self multiple not]
]

{ #category : #testing }
SBTSNodeRepeat >> isTSRepeat [

	^ true
]

{ #category : #printing }
SBTSNodeRepeat >> labelPrintOn: aStream [

	self element labelPrintOn: aStream
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
SBTSNodeRepeat >> multiple: aBoolean required: anotherBoolean element: aNode [

	multiple := aBoolean.
	required := anotherBoolean.
	element := aNode.
	
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

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> required: aBoolean [

	required := aBoolean
]

{ #category : #parsing }
SBTSNodeRepeat >> resultsFor: aParser [

	| candidates queue |
	candidates := self required
		ifTrue: [OrderedCollection new]
		ifFalse: [OrderedCollection with: aParser].
	queue := OrderedCollection with: aParser.
	
	[queue isEmpty] whileFalse: [ | next lastPosition |
		next := queue removeFirst copy.
		lastPosition := next position.
		(self element resultsFor: next) do: [:result |
			delimiter ifNotNil: [result stream nextMatchAll: delimiter].
			candidates add: result.
			(multiple and: [result position > lastPosition and: [result atEnd not]]) ifTrue: [queue add: result]]].
	
	^ candidates
]

{ #category : #parsing }
SBTSNodeRepeat >> resultsForBlocks: aParser [

	| queue |
	queue := OrderedCollection with: aParser.
	^ (Array streamContents: [:stream |
		[queue notEmpty] whileTrue: [ | results parser currentPosition wasAtEnd |
			parser := queue removeFirst copy.
			currentPosition := parser position.
			wasAtEnd := parser atEnd.
			(parser peekForLabel: delimiter) ifTrue: [parser nextSibling].
			self isStatementRepeater ifTrue: [
				parser numberOfNewLinesToNext - 1 timesRepeat: [parser addBlock: (element alternatives atLast: 2) buildEmpty first].
				parser popPendingComments do: [:comment |
					parser addBlock: (element alternatives last buildEmpty first
						contents: comment;
						yourself)]].
			results := self element resultsForBlocks: parser.
			results do: [:candidate |
				"to fix troubles with infinitely repeating matches, we only accept results if they advanced the parser."
				(candidate position > currentPosition or: [wasAtEnd not and: [candidate atEnd]]) ifTrue: [
					(candidate peekForLabel: delimiter) ifTrue: [candidate nextSibling].
					self isStatementRepeater ifTrue: [
						candidate popPendingComments do: [:comment |
							candidate addBlock: (element alternatives last buildEmpty first
								contents: comment;
								yourself)]].
					stream nextPut: candidate.
					multiple ifTrue: [queue add: candidate]]]]]) ifEmpty: [
		self required ifTrue: [{}] ifFalse: [
			self isStatementRepeater ifTrue: [
				aParser popPendingComments do: [:comment |
					aParser addBlock: (element alternatives last buildEmpty first
						contents: comment;
						yourself)]].
			{aParser}]]
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
			(parser peek isString and: [parser peek = delimiter]) ifTrue: [
				parser next.
				parser addSlot: SBTSNodeBlank new].
			results := self element takeNodesFrom: parser.
			results do: [:candidate |
				"to fix troubles with infinitely repeating matches, we only accept results
if they advanced the parser."
				candidate position > currentPosition ifTrue: [
					(candidate peek isString and: [candidate peek = delimiter]) ifTrue: [
						candidate next.
						candidate addSlot: SBTSNodeBlank new].
					stream nextPut: candidate.
					queue add: {candidate. index}]]]]) ifEmpty: [self required ifTrue: [{}] ifFalse: [{aParser copy}]]
]

{ #category : #'as yet unclassified' }
SBTSNodeRepeat >> transformToStatementRepeater [

	| current choice lang alts |
	lang := self factory language.
	self isStatementRepeater: true.
	current := self element.
	choice := SBTSNodeChoice new factory: self factory.
	current replaceBy: choice.
	alts := {current}, (lang emptyLineSymbol
		ifNotNil: [:sym |
			{
				SBTSNodeSymbol new
					type: sym factory: self factory;
					hidden: true}]
		ifNil: [{}]), (lang commentSymbol
		ifNotNil: [:sym |
			{
				SBTSNodeSymbol new
					type: sym factory: self factory;
					hidden: true}]
		ifNil: [{}]).
	choice alternatives: alts
]

{ #category : #hierarchy }
SBTSNodeRepeat >> traverseBlocks: aStream do: aBlock [

	[aStream atEnd not and: [aStream peek slot includesParent: self]] whileTrue: [element traverseBlocks: aStream do: aBlock]
]

{ #category : #printing }
SBTSNodeRepeat >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
