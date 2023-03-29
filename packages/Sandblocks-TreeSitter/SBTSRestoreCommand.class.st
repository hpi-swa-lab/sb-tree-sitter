Class {
	#name : #SBTSRestoreCommand,
	#superclass : #SBCommand,
	#instVars : [
		'source',
		'target'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSRestoreCommand >> do [

	target allMorphsDo: [:m | (m class = SBTSReplacedBlockContainer and: [m firstSubmorph class = SBTSReplacementPlaceholder]) ifTrue: [m block swapWith: m firstSubmorph]].
	^ target
]

{ #category : #'as yet unclassified' }
SBTSRestoreCommand >> setArtefactFrom [

	^ source
]

{ #category : #'as yet unclassified' }
SBTSRestoreCommand >> source: aBlock [

	source := aBlock
]

{ #category : #'as yet unclassified' }
SBTSRestoreCommand >> target: aBlock [

	target := aBlock
]

{ #category : #'as yet unclassified' }
SBTSRestoreCommand >> undo [

	source allMorphsDo: [:m | m class = SBTSReplacementPlaceholder ifTrue: [m swapWith: m replaces block]].
	^ source
]
