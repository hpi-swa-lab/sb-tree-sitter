Class {
	#name : #SBTSFileParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'slots'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSFileParser >> addSlot: aNode [

	slots add: (SBTSSlot new addNode: aNode)
]

{ #category : #stream }
SBTSFileParser >> atEnd [

	^ stream atEnd
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
	
	slots := OrderedCollection new
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
					(atEnd not and: [aCursor factory noteUncapturedText includes: type]) ifTrue: [
						gap := aCursor textBetween: current and: aCursor node.
						gap size > 0 ifTrue: [s nextPut: gap].
						current := aCursor node].
					atEnd].
				aCursor gotoParent]].
		blocks := fields ifEmpty: [aCursor text ifEmpty: [#()] ifNotEmpty: [{aCursor text}]].
		stream := (blocks collect: [:b | b isString ifTrue: [b] ifFalse: [b slot firstNode]]) readStream.
		slots := OrderedCollection new.
		matches := template takeNodesFrom: self.
		self assert: matches ~= #noMatch description: ('could not construct `{1}`' format: {type}).
		matches := matches select: [:match | match atEnd].
		self assert: matches size = 1.
		
		SBTSBlock new
			slot: (SBTSSlot new addNode: (SBToggledCode comment: '' active: 1 do: {
				[
					isAlias
						ifTrue: [
							SBTSNodeAlias new
								factory: template factory;
								alias: aCursor type;
								element: (SBTSNodeSymbol new type: type factory: template factory)]
						ifFalse: [SBTSNodeSymbol new type: type factory: template factory]].
				[SBTSNodeSymbol new type: type factory: template factory]}));
			addAllMorphs: (blocks with: matches first slots collect: [:subBlock :slot | slot buildMorphWith: subBlock]);
			yourself]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> parse: aString language: aFactory [

	| api |
	api := SBTreeSitter new.
	^ api parseAsCursor: aString language: aFactory class language do: [:cursor |
		self nodeForCursor: (SBTSCursor new library: api cursor: cursor factory: aFactory)]
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
	slots := slots copy
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
