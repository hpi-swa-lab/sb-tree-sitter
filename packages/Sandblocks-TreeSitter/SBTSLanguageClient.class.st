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
		'serverMessageHandler',
		'transport',
		'serverCapabilities'
	],
	#classVars : [
		'LogLanguageServerCommunication'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBTSLanguageClient class >> logLanguageServerCommunication [
	<preference: 'Log Language Server communication' category: 'Sandblocks' description: '' type: #Boolean>

	^ LogLanguageServerCommunication ifNil: [false]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient class >> logLanguageServerCommunication: aBoolean [

	LogLanguageServerCommunication := aBoolean
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> close [

	self stop
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> connected [

	^ transport connected
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> formatRequest: aString params: anObject seq: myId [

	^ Dictionary newFrom: {'jsonrpc' -> '2.0'. 'id' -> myId. 'method' -> aString. 'params' -> anObject}
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
				ifAbsent: [self log: {'unknown message'. aJsonObject}]]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> handleServerMessage: aJsonObject [

	serverMessageHandler value: aJsonObject
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> initialize [

	super initialize.
	
	serverCapabilities := Dictionary new.
	pending := Dictionary new.
	lastRequestId := 0
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> initializeFor: aDirectory onServerMessageDo: aBlock onReady: anotherBlock transport: aTransport [

	transport := aTransport languageClient: self.
	serverMessageHandler := aBlock.
	projectDirectory := aDirectory.
	
	transport start.
	
	transport connected
		ifTrue: [self sendInitializeDo: anotherBlock]
		ifFalse: [self error: 'Could not connect']
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> internalSend: aBlock [

	| myId promise |
	myId := lastRequestId := lastRequestId + 1.
	promise := Promise new.
	pending at: myId put: promise.
	self send: (aBlock value: myId).
	^ promise
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> internalSendRequest: aString params: anObject [

	^ self internalSend: [:myId | self formatRequest: aString params: anObject seq: myId]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> log: anObject [

	self class logLanguageServerCommunication ifTrue: [Transcript showln: anObject]
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

	transport restart
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> send: aJsonObject [

	transport send: aJsonObject
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendAsyncRequest: aString params: anObject do: aBlock [

	^ (self internalSendRequest: aString params: anObject) then: [:response |
		self onUIThread: [aBlock value: response].
		response]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendBlockingRequest: aString params: anObject do: aBlock [

	^ aBlock value: (self internalSendRequest: aString params: anObject) wait
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendInitializeDo: aBlock [

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
			serverCapabilities := response at: 'capabilities'.
			self log: 'Connected to server'.
			self sendNotification: 'initialized' params: Dictionary new.
			aBlock value]
		blocking: false
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendNotification: aString params: anObject [

	lastRequestId := lastRequestId + 1.
	self send: (Dictionary newFrom: {'jsonrpc' -> '2.0'. 'method' -> aString. 'params' -> anObject})
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> sendRequest: aString params: anObject do: aBlock blocking: aBoolean [

	^ aBoolean
		ifTrue: [self sendBlockingRequest: aString params: anObject do: aBlock]
		ifFalse: [self sendAsyncRequest: aString params: anObject do: aBlock]
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> serverSupportsDocumentHighlight [

	^ (serverCapabilities at: 'documentHighlightProvider' ifAbsent: [false]) ~~ false
]

{ #category : #'as yet unclassified' }
SBTSLanguageClient >> stop [

	transport stop
]
