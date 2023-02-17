Class {
	#name : #SBLSPStdioTransport,
	#superclass : #SBLSPTransport,
	#instVars : [
		'command',
		'arguments',
		'process',
		'inputPipe',
		'outputPipe',
		'workingDirectory',
		'messageProcess'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBLSPStdioTransport >> arguments: aCollection [

	arguments := aCollection
]

{ #category : #'as yet unclassified' }
SBLSPStdioTransport >> command: aString [

	command := aString
]

{ #category : #'as yet unclassified' }
SBLSPStdioTransport >> start [

	super start.
	
	inputPipe := OSPipe blockingPipe.
	outputPipe := OSPipe nonBlockingPipe.
	
	process := ExternalUnixOSProcess
		forkAndExec: command
		arguments: arguments
		environment: nil
		descriptors: {inputPipe ifNotNil: #reader. outputPipe writer. nil}
		workingDir: workingDirectory.
	
	outputPipe writer close.
	inputPipe reader close.
	
	messageProcess := [[outputPipe closed not and: [process runState ~= #complete]] whileTrue: [self readFrom: outputPipe upToEnd]] fork
]

{ #category : #'as yet unclassified' }
SBLSPStdioTransport >> stop [

	messageProcess terminate.
	process sigterm.
	inputPipe close
]

{ #category : #'as yet unclassified' }
SBLSPStdioTransport >> workingDirectory: aString [

	workingDirectory := aString
]

{ #category : #'as yet unclassified' }
SBLSPStdioTransport >> writer [

	inputPipe writer closed ifTrue: [self restart].
	^ inputPipe writer
]
