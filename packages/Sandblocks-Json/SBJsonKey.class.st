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
		if: [converter objectInterface first class = SBTSObjectInterface and: [converter objectInterface first slot language = SBPython and: [(target adaptSlotFor: converter objectInterface first slot ifFailed: [false]) ~~ false]]]
		do: [target adaptSlotFor: converter objectInterface first slot ifFailed: [self assert: false]]
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
	target := SBPython parseExpression: self keys.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		addMorphBack: (SBStringMorph new contents: aBlock contents)
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
