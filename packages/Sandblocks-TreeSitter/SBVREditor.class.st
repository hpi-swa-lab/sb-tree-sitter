Class {
	#name : #SBVREditor,
	#superclass : #SBEditor,
	#instVars : [
		'commandQueue',
		'godotProvider',
		'currentId'
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

{ #category : #'as yet unclassified' }
SBVREditor >> do: aCommand [

	super do: aCommand.
	commandQueue add: aCommand
]

{ #category : #'as yet unclassified' }
SBVREditor >> getNextId [

	currentId := currentId + 1.
	^ currentId
]

{ #category : #'as yet unclassified' }
SBVREditor >> godotProvider [

	^ godotProvider
]

{ #category : #'as yet unclassified' }
SBVREditor >> godotProvider: anObject [

	godotProvider := anObject
]

{ #category : #'as yet unclassified' }
SBVREditor >> initialize [

	super initialize.
	
	currentId := 0.
	commandQueue := OrderedCollection new
]

{ #category : #'as yet unclassified' }
SBVREditor >> vrDoQueuedCommands [

	commandQueue do: [:command | command vrDo].
	commandQueue removeAll
]
