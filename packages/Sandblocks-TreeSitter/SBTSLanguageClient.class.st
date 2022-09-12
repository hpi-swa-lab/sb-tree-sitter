Class {
	#name : #SBTSLanguageClient,
	#superclass : #Object,
	#instVars : [
		'process',
		'inputPipe',
		'lastRequestId',
		'projectDirectory',
		'pending',
		'buffer',
		'notificationHandler'
	],
	#category : #'Sandblocks-TreeSitter-Project'
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
	message := Json readFrom: data readStream.
	Project current addDeferredUIMessage: [self handleMessage: message].
	buffer := readBuffer upToEnd.
	^ true
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> handleMessage: aJsonObject [

	(aJsonObject includesKey: 'id')
		ifTrue: [
			pending
				at: aJsonObject id
				ifPresent: [:block |
					pending removeKey: aJsonObject id.
					(aJsonObject includesKey: 'error') ifTrue: [^ self error: aJsonObject error].
					block value: aJsonObject result]
				ifAbsent: [Transcript showln: {'unknown message'. aJsonObject}]]
		ifFalse: [self handleNotification: aJsonObject]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> handleNotification: aJsonObject [

	notificationHandler value: aJsonObject
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> initializeFor: aDirectory onNotificationDo: aBlock [

	| outputPipe |
	super initialize.
	
	notificationHandler := aBlock.
	pending := Dictionary new.
	projectDirectory := aDirectory.
	lastRequestId := 0.
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
		workingDir: aDirectory pathString.
	outputPipe writer close.
	inputPipe reader close.
	
	[
		[outputPipe closed not and: [process runState ~= #complete]] whileTrue: [
			(Delay forMilliseconds: 20) wait.
			buffer := buffer, outputPipe upToEnd.
			[self handleData] whileTrue]] fork.
	
	self sendInitialize
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> send: aJsonObject [

	| payload |
	payload := aJsonObject asJsonString utf8Encoded.
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

	| myId |
	myId := lastRequestId := lastRequestId + 1.
	pending at: myId put: aBlock.
	self send: (Dictionary newFrom: {'jsonrpc' -> '2.0'. 'id' -> myId. 'method' -> aString. 'params' -> anObject})
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendBlockingRequest: aString params: anObject do: aBlock [

	| semaphore |
	semaphore := Semaphore new.
	self sendAsyncRequest: aString params: anObject do: [:response |
		aBlock value: response.
		semaphore signal].
	semaphore wait
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
					'synchronization' -> (Dictionary newFrom: {'dynamicRegistration' -> true})})})})
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
SBTSLanguageClient >> stop [

	process sigterm.
	inputPipe close
]
