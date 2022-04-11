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

{ #category : #blocks }
SBTSNodeRepeat >> allChildrenDo: aBlock [

	aBlock value: self.
	self element allChildrenDo: aBlock
]

{ #category : #blocks }
SBTSNodeRepeat >> buildEmpty [

	^ self required ifTrue: [self element buildEmpty] ifFalse: [{}]
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
SBTSNodeRepeat >> element [

	^ element
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
SBTSNodeRepeat >> isTSOptional [

	^ self required not and: [self multiple not]
]

{ #category : #testing }
SBTSNodeRepeat >> isTSRepeat [

	^ true
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
	results := self element resultsFor: aParser copy.
	^ self required
		ifTrue: [results]
		ifFalse: [{aParser copy}, (results = #noMatch ifTrue: [#()] ifFalse: [results])]
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

{ #category : #hierarchy }
SBTSNodeRepeat >> traverseBlocks: aStream do: aBlock [

	[aStream atEnd not and: [aStream peek slot includesParent: self]] whileTrue: [element traverseBlocks: aStream do: aBlock]
]

{ #category : #printing }
SBTSNodeRepeat >> writeSourceOn: aStream indent: aNumber [

	self printElementsSeparated: self submorphs on: aStream indent: aNumber
]
