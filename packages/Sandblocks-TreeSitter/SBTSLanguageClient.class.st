Class {
	#name : #SBTSLanguageClient,
	#superclass : #Object,
	#instVars : [
		'process',
		'messageProcess',
		'inputPipe',
		'lastRequestId',
		'projectDirectory',
		'pending',
		'buffer',
		'serverMessageHandler'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> handleData [

	| length message data readBuffer |
	readBuffer := buffer readStream.
	(readBuffer nextMatchAll: 'Content-Length: ') ifFalse: [^ false].
	(readBuffer peekDuring: [readBuffer skipTo: Character cr]) ifFalse: [^ false].
	length := (readBuffer upTo: Character cr) asNumber.
	(readBuffer nextMatchAll: String lf, String crlf) ifFalse: [^ false].
	data := readBuffer next: length.
	data size ~= length ifTrue: [^ false].
	message := Json readFrom: data utf8ToSqueak readStream.
	self handleMessage: message.
	buffer := readBuffer upToEnd.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> handleMessage: aJsonObject [

	(aJsonObject includesKey: 'method')
		ifTrue: [self onUIThread: [self handleServerMessage: aJsonObject]]
		ifFalse: [
			pending
				at: aJsonObject id
				ifPresent: [:promise |
					pending removeKey: aJsonObject id.
					(aJsonObject includesKey: 'error') ifTrue: [ | error |
						error := aJsonObject at: 'error'.
						promise rejectWith: error.
						^ self onUIThread: [self error: error]].
					promise resolveWith: aJsonObject result]
				ifAbsent: [Transcript showln: {'unknown message'. aJsonObject}]]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> handleServerMessage: aJsonObject [

	serverMessageHandler value: aJsonObject
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> initializeFor: aDirectory onServerMessageDo: aBlock [

	super initialize.
	
	serverMessageHandler := aBlock.
	pending := Dictionary new.
	projectDirectory := aDirectory.
	lastRequestId := 0.
	
	self start
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> internalSendRequest: aString params: anObject [

	| myId promise |
	myId := lastRequestId := lastRequestId + 1.
	promise := Promise new.
	pending at: myId put: promise.
	self send: (Dictionary newFrom: {'jsonrpc' -> '2.0'. 'id' -> myId. 'method' -> aString. 'params' -> anObject}).
	^ promise
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> onUIThread: aBlock [

	Project current addDeferredUIMessage: aBlock
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> respondToRequest: aNumber error: anObject [

	self send: (Dictionary newFrom: {'id' -> aNumber. 'error' -> anObject})
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> respondToRequest: aNumber result: anObject [

	self send: (Dictionary newFrom: {'id' -> aNumber. 'result' -> anObject})
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> restart [

	self
		stop;
		start
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> send: aJsonObject [

	| payload |
	payload := aJsonObject asJsonString utf8Encoded.
	inputPipe writer closed ifTrue: [self restart].
	inputPipe writer
		nextPutAll: 'Content-Length: ';
		nextPutAll: payload size asString;
		cr;
		lf;
		cr;
		lf;
		nextPutAll: payload;
		flush
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendAsyncRequest: aString params: anObject do: aBlock [

	(self internalSendRequest: aString params: anObject) then: [:response | self onUIThread: [aBlock value: response]]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendBlockingRequest: aString params: anObject do: aBlock [

	aBlock value: (self internalSendRequest: aString params: anObject) wait
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendInitialize [

	self
		sendRequest: 'initialize'
		params: (Dictionary newFrom: {
			'processId' -> nil.
			'clientInfo' -> (Dictionary newFrom: {'name' -> 'sandblocks'}).
			'rootUri' -> ('file://', projectDirectory pathString).
			'capabilities' -> (Dictionary newFrom: {
				'textDocument' -> (Dictionary newFrom: {
					'hover' -> (Dictionary newFrom: {}).
					'synchronization' -> (Dictionary newFrom: {'dynamicRegistration' -> true})}).
				'workspace' -> (Dictionary newFrom: {'applyEdit' -> true. 'workspaceEdit' -> (Dictionary newFrom: {'documentChanges' -> true})})})})
		do: [:response |
			Transcript showln: 'Connected to server'.
			self sendNotification: 'initialized' params: Dictionary new]
		blocking: false
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendNotification: aString params: anObject [

	lastRequestId := lastRequestId + 1.
	self send: (Dictionary newFrom: {'jsonrpc' -> '2.0'. 'method' -> aString. 'params' -> anObject})
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendRequest: aString params: anObject do: aBlock blocking: aBoolean [

	aBoolean
		ifTrue: [self sendBlockingRequest: aString params: anObject do: aBlock]
		ifFalse: [self sendAsyncRequest: aString params: anObject do: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> start [

	| outputPipe |
	inputPipe := OSPipe blockingPipe.
	outputPipe := OSPipe nonBlockingPipe.
	buffer := ''.
	
	process := ExternalUnixOSProcess
		forkAndExec: (SBTSLanguageRuntime which: 'typescript-language-server')
		arguments: (SBToggledCode comment: '' active: 1 do: {
			[{'--stdio'}].
			[{'--stdio'. '--log-level'. '4'. '--tsserver-log-file'. '/home/tom/ts.log'. '--tsserver-log-verbosity'. 'verbose'}]})
		environment: nil
		descriptors: {inputPipe ifNotNil: #reader. outputPipe writer. nil}
		workingDir: projectDirectory pathString.
	outputPipe writer close.
	inputPipe reader close.
	
	messageProcess := [
		[outputPipe closed not and: [process runState ~= #complete]] whileTrue: [
			(Delay forMilliseconds: 20) wait.
			buffer := buffer, outputPipe upToEnd.
			[self handleData] whileTrue]] fork.
	
	self sendInitialize
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> stop [

	messageProcess terminate.
	process sigterm.
	inputPipe close
]
