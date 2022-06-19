Class {
	#name : #SBTSFileParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'slots',
		'blocks',
		'cursor',
		'pendingText',
		'justEnteredAlias'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #blocks }
SBTSFileParser >> addBlock: aBlock [

	self assert: aBlock isTSMorph.
	blocks add: aBlock
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> addSlot: aNode [

	slots add: (SBTSSlot with: aNode)
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> ascend [

	^ pendingText
		ifNotNil: [
			pendingText := nil.
			true]
		ifNil: [ | success |
			success := cursor atEnd.
			cursor gotoParent.
			success]
]

{ #category : #stream }
SBTSFileParser >> atEnd [

	^ cursor atEnd
]

{ #category : #blocks }
SBTSFileParser >> blocks [

	^ blocks
]

{ #category : #blocks }
SBTSFileParser >> blocks: aCollection [

	blocks := aCollection
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> blocksForCursor: aCursor [

	aCursor isNamed ifFalse: [^ {aCursor text}].
	^ aCursor currentDo: [:type :template :isAlias | | fields matches result |
		fields := Array streamContents: [:s |
			aCursor gotoFirstChild ifTrue: [ | current |
				current := aCursor node.
				[s nextPutAll: (self blocksForCursor: aCursor)] doWhileFalse: [ | gap atEnd |
					atEnd := aCursor gotoNextSibling.
					(aCursor factory noteUncapturedText includes: type) ifTrue: [
						gap := aCursor textBetween: current and: (atEnd ifTrue: [nil] ifFalse: [aCursor node]).
						gap size > 0 ifTrue: [s nextPut: gap].
						current := aCursor node].
					atEnd].
				aCursor gotoParent]].
		stream := (fields ifEmpty: [aCursor text ifEmpty: [#()] ifNotEmpty: [{aCursor text}]]) readStream.
		blocks := OrderedCollection new.
		matches := template resultsForBlocks: self.
		self assert: matches notEmpty description: ('could not construct `{1}`' format: {type}).
		matches := matches select: [:match | match atEnd].
		self assert: matches size = 1.
		
		result := SBTSBlock new
			slot: (SBTSSlot with: (isAlias
				ifTrue: [
					SBTSNodeAlias new
						factory: template factory;
						alias: aCursor type;
						element: template]
				ifFalse: [SBTSNodeSymbol new type: type factory: template factory]));
			addAllMorphs: matches anyOne blocks;
			yourself.
		result slot lastNode isBlockInlined
			ifTrue: [
				result slot lastNode isBlockInlinedInParent ifFalse: [result submorphs do: [:m | m slot: (m slot addNode: result slot lastNode)]].
				result submorphs]
			ifFalse: [{result}]]
]

{ #category : #stream }
SBTSFileParser >> contentsSize [

	^ stream originalContents size
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> currentSlot [

	^ slots last
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> cursor [

	^ cursor
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> descend [

	cursor gotoFirstChild ifFalse: [pendingText := cursor text]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> initialize [

	super initialize.
	
	slots := OrderedCollection new.
	blocks := OrderedCollection new.
	justEnteredAlias := false
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> justEnteredAlias [

	^ justEnteredAlias
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> justEnteredAlias: aBoolean [

	justEnteredAlias := aBoolean
]

{ #category : #stream }
SBTSFileParser >> nextFor: aNode [

	| currentBlocks result |
	cursor gotoFirstChild ifFalse: [cursor text].
	currentBlocks := blocks.
	blocks := OrderedCollection new.
	aNode bodyTemplate resultsForBlocks: self.
	result := SBTSBlock new
		addAllMorphs: blocks;
		slot: (SBTSSlot with: aNode).
	blocks := currentBlocks.
	^ result
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> nextSibling [

	cursor gotoNextSibling
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> nodeForCursor: aCursor [

	aCursor isNamed ifFalse: [^ aCursor text].
	^ aCursor currentDo: [:type :template :isAlias | | fields matches blocks |
		fields := Array streamContents: [:s |
			aCursor gotoFirstChild ifTrue: [ | current |
				current := aCursor node.
				[s nextPut: (self nodeForCursor: aCursor)] doWhileFalse: [ | gap atEnd |
					atEnd := aCursor gotoNextSibling.
					(aCursor factory noteUncapturedText includes: type) ifTrue: [
						gap := aCursor textBetween: current and: (atEnd ifTrue: [nil] ifFalse: [aCursor node]).
						gap size > 0 ifTrue: [s nextPut: gap].
						current := aCursor node].
					atEnd].
				aCursor gotoParent]].
		blocks := fields ifEmpty: [aCursor text ifEmpty: [#()] ifNotEmpty: [{aCursor text}]].
		stream := (blocks collect: [:b | b isString ifTrue: [b] ifFalse: [b slot firstNode]]) readStream.
		slots := OrderedCollection new.
		matches := template takeNodesFrom: self.
		self assert: matches notEmpty description: ('could not construct `{1}`' format: {type}).
		matches := matches select: [:match | match atEnd].
		self assert: matches size = 1.
		
		SBTSBlock new
			slot: (SBTSSlot with: (isAlias
				ifTrue: [
					SBTSNodeAlias new
						factory: template factory;
						alias: aCursor type;
						element: template]
				ifFalse: [SBTSNodeSymbol new type: type factory: template factory]));
			addAllMorphs: (blocks with: matches first slots collect: [:subBlock :slot | slot buildMorphWith: subBlock]) flatten;
			yourself]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> parse: aString language: aLanguage [

	| api language |
	api := SBTreeSitter new.
	language := aLanguage isBehavior ifTrue: [aLanguage instance] ifFalse: [aLanguage].
	^ api parseAsCursor: aString language: language class language do: [:cursorObj | | results |
		cursor := SBTSCursor new library: api cursor: cursorObj factory: language grammar.
		results := (SBTSNodeSymbol new
			type: language class rootRuleName
			factory: language grammar) resultsForBlocks: self.
		self assert: results size = 1.
		self assert: results anyOne blocks size = 1.
		results anyOne blocks anyOne]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> parseTopLevel: aString language: aFactory [

	| toplevel |
	toplevel := self parse: aString language: aFactory.
	toplevel
		hResizing: #rigid;
		layoutInset: 12;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured.
	^ toplevel
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> peekHasText [

	^ pendingText notNil
]

{ #category : #stream }
SBTSFileParser >> peekIsNamed [

	^ cursor isNamed
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> peekText [

	^ pendingText
]

{ #category : #stream }
SBTSFileParser >> peekType [

	^ cursor type
]

{ #category : #stream }
SBTSFileParser >> position [

	^ cursor currentIndex
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> postCopy [

	super postCopy.
	blocks := blocks collect: [:block | block copyBlock].
	cursor := cursor copy
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> replaceCurrentSlot: aSlot [

	slots removeLast.
	slots add: aSlot
]

{ #category : #accessing }
SBTSFileParser >> slots [

	^ slots
]

{ #category : #accessing }
SBTSFileParser >> stream [

	^ stream
]

{ #category : #accessing }
SBTSFileParser >> stream: aStream [

	stream := aStream
]
