Class {
	#name : #SBJsonKey,
	#superclass : #SBBlock,
	#instVars : [
		'source',
		'target'
	],
	#category : #'Sandblocks-Json'
}

{ #category : #'as yet unclassified' }
SBJsonKey >> asAccess: converter [
	<convert>

	converter
		if: [converter objectInterface first class = SBTSObjectInterface and: [converter objectInterface first slot language = target language and: [(target adaptSlotFor: converter objectInterface first slot ifFailed: [false]) ~~ false]]]
		do: [
			SBToggledCode comment: '' active: 1 do: {
				[target adaptSlotFor: converter objectInterface first slot ifFailed: [self assert: false]].
				[ | drop |
					drop := (SBPython parseToplevel: (self sourceForContext: converter objectInterface first at block)) applyReplacements childSandblocks first.
					drop adaptSlotFor: converter objectInterface first slot ifFailed: [self assert: false]]}]
]

{ #category : #'as yet unclassified' }
SBJsonKey >> chainInContext: aBlock [

	| chain full |
	chain := (source allOwners reversed select: [:i | i isTSBlock and: [#(#pair #array) includes: i type]]) as: OrderedCollection.
	full := chain copy.
	
	(Array streamContents: [:stream |
		((aBlock allOwners reversed select: [:o | o class = SBMapList]) collect: [:o | o access]) do: [:a |
			stream nextPutAll: ((a allBlocksSelect: [:b | b type = #string]) collect: #contents).
			stream nextPut: '[]']]) do: [:x |
		((x = '[]' and: [chain first type = #array]) or: [(chain first get: 'key') contents = x])
			ifTrue: [chain removeFirst]
			ifFalse: [^ full]].
	^ chain
]

{ #category : #'as yet unclassified' }
SBJsonKey >> keys [

	^ self
		wrap: 'src'
		list: (source allOwners reversed select: [:i | i isTSBlock and: [#(#pair #array) includes: i type]])
]

{ #category : #'as yet unclassified' }
SBJsonKey >> source: aBlock [

	source := aBlock.
	target := SBToggledCode comment: '' active: 1 do: {
		[(SBJavascript parseExpression: ('<>\{mtrack.{1}\}</>' format: {source contents})) childSandblocks first].
		[(SBPython parseToplevel: self keys) applyReplacements childSandblocks first]}.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		addMorphBack: (SBStringMorph new contents: aBlock contents)
]

{ #category : #'as yet unclassified' }
SBJsonKey >> sourceForContext: aBlock [

	^ self wrap: 'src' list: (self chainInContext: aBlock)
]

{ #category : #'as yet unclassified' }
SBJsonKey >> wrap: src list: list [

	list ifEmpty: [^ src].
	(list first isTSBlock and: [list first type = #pair]) ifTrue: [^ self wrapAttr: src list: list].
	(list first isTSBlock and: [list first type = #array]) ifTrue: [^ self wrapArray: src list: list].
	self assert: false
]

{ #category : #'as yet unclassified' }
SBJsonKey >> wrapArray: src list: list [

	^ 'list(map(lambda src: {1}, {2}))' format: {self wrap: 'src' list: list allButFirst. src}
]

{ #category : #'as yet unclassified' }
SBJsonKey >> wrapAttr: src list: list [

	^ self wrap: ('{1}["{2}"]' format: {src. (list first get: 'key') contents}) list: list allButFirst
]
