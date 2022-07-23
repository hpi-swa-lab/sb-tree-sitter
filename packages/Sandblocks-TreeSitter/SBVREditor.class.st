Class {
	#name : #SBVREditor,
	#superclass : #SBEditor,
	#instVars : [
		'commandQueue',
		'godotProvider',
		'currentId',
		'vrIdToMorph',
		'tempInsertRegistry'
	],
	#classVars : [
		'Instance'
	],
	#classInstVars : [
		'commandQueue'
	],
	#category : #'Sandblocks-TreeSitter-VR'
}

{ #category : #'as yet unclassified' }
SBVREditor class >> current [

	^ Instance := Instance ifNil: [self new openInWindow; yourself]
]

{ #category : #'action helpers' }
SBVREditor >> do: aCommand [

	super do: aCommand.
	commandQueue add: aCommand
]

{ #category : #'id mapping' }
SBVREditor >> getNextId [

	currentId := currentId + 1.
	^ currentId
]

{ #category : #accessing }
SBVREditor >> godotProvider [

	^ godotProvider
]

{ #category : #accessing }
SBVREditor >> godotProvider: anObject [

	godotProvider := anObject
]

{ #category : #initialization }
SBVREditor >> initialize [

	super initialize.
	
	currentId := 0.
	commandQueue := OrderedCollection new.
	
	vrIdToMorph := Dictionary new.
]

{ #category : #'insert commands' }
SBVREditor >> insertCommandAtId: aNumber [

	^ tempInsertRegistry at: aNumber
]

{ #category : #'insert commands' }
SBVREditor >> insertPositionsFor: aBlock [

	tempInsertRegistry := Dictionary new.
	^ (Array streamContents: [:stream |
		self cursorPositionsDo: [:pos |
			(pos isInsert and: [pos container isTSBlock]) ifTrue: [ | targetType id |
				targetType := pos command element.
				(aBlock adaptSlotFor: (SBTSSlot with: targetType) ifFailed: [nil]) ifNotNil: [:adaptedCopy |
					id := self getNextId.
					pos command morphs: {adaptedCopy}.
					tempInsertRegistry at: id put: pos command.
					stream nextPut: (Dictionary newFrom: {
						#id -> id.
						#depth -> pos container blockDepth.
						#bounds -> ((pos bounds translateBy: pos container containingFloat position negated) in: [:r | {r left. r top. r width. r height}]).
						#floatId -> pos container containingFloat vrId})]]]]) asJsonString
]

{ #category : #'id mapping' }
SBVREditor >> morphAtVrId: vrId [

	^ vrIdToMorph at: vrId
]

{ #category : #'id mapping' }
SBVREditor >> registerMorph: aMorph atVrId: aNumber [

	vrIdToMorph at: aNumber put: aMorph
]

{ #category : #'insert commands' }
SBVREditor >> showInsertPositionsFor: aBlock [

	self godotProvider showInsertPositions: (self insertPositionsFor: aBlock)
]

{ #category : #'action helpers' }
SBVREditor >> vrDoQueuedCommands [

	commandQueue do: [:command | command vrDo].
	commandQueue removeAll
]

{ #category : #'id mapping' }
SBVREditor >> vrIds [

	^ vrIdToMorph keys
]
