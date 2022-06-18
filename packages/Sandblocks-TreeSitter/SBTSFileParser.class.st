Class {
	#name : #SBTSFileParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'slots',
		'blocks'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #blocks }
SBTSFileParser >> addBlock: aBlock [

	blocks add: aBlock
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> addSlot: aNode [

	slots add: (SBTSSlot with: aNode)
]

{ #category : #stream }
SBTSFileParser >> atEnd [

	^ stream atEnd
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
SBTSFileParser >> initialize [

	super initialize.
	
	slots := OrderedCollection new.
	blocks := OrderedCollection new
]

{ #category : #stream }
SBTSFileParser >> next [

	^ stream next
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
SBTSFileParser >> parse: aString language: aFactory [

	| api language |
	api := SBTreeSitter new.
	language := aFactory isBehavior ifTrue: [aFactory instance] ifFalse: [aFactory].
	^ api parseAsCursor: aString language: language class language do: [:cursor | | result |
		result := self blocksForCursor: (SBTSCursor new library: api cursor: cursor factory: language grammar).
		self assert: result size = 1.
		result anyOne]
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

{ #category : #stream }
SBTSFileParser >> peek [

	^ stream peek
]

{ #category : #stream }
SBTSFileParser >> position [

	^ stream position
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> postCopy [

	super postCopy.
	stream := (ReadStream on: stream contents)
		position: stream position;
		yourself.
	slots := slots copy.
	blocks := blocks copy
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
