Class {
	#name : #SBTSDebugAdapterClient,
	#superclass : #SBTSLanguageClient,
	#instVars : [
		'launchConfig',
		'session',
		'initializationPromise',
		'parent'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #requests }
SBTSDebugAdapterClient >> attach: arguments do: aBlock [

	self sendRequest: 'attach' params: arguments do: [:res | aBlock value] blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> breakpointLocationsIn: aFilePathString at: aLineNumber [

	^ self
		sendBlockingRequest: 'breakpointLocations'
		params: (Dictionary newFrom: {'source' -> (Dictionary newFrom: {'path' -> aFilePathString}). 'line' -> aLineNumber})
		do: [:r | r breakpoints]
]

{ #category : #requests }
SBTSDebugAdapterClient >> close [

	[self disconnect] on: ConnectionTimedOut, SocketPrimitiveFailed, Error do: [].
	super close
]

{ #category : #requests }
SBTSDebugAdapterClient >> continue: aThreadIdNumber [

	self
		sendRequest: 'continue'
		params: (Dictionary newFrom: {'threadId' -> aThreadIdNumber})
		do: [:res | ]
		blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> disconnect [

	self sendRequest: 'disconnect' params: Dictionary new do: [:res | ] blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> evaluate: aString in: aFrameId [

	^ [
		self
			sendBlockingRequest: 'evaluate'
			params: (Dictionary newFrom: {'expression' -> aString. 'context' -> 'repl'. 'frameId' -> aFrameId})
			do: [:r | r]]
		on: BrokenPromise
		do: [:p | self error: p reason]
]

{ #category : #communication }
SBTSDebugAdapterClient >> formatRequest: aString params: anObject seq: myId [

	^ Dictionary newFrom: {'type' -> 'request'. 'seq' -> myId. 'command' -> aString. 'arguments' -> anObject}
]

{ #category : #requests }
SBTSDebugAdapterClient >> gotoTargetsIn: aFilePathString at: aLineNumber [

	^ self
		sendBlockingRequest: 'gotoTargets'
		params: (Dictionary newFrom: {'source' -> (Dictionary newFrom: {'path' -> aFilePathString}). 'line' -> aLineNumber})
		do: [:r | r]
]

{ #category : #communication }
SBTSDebugAdapterClient >> handleMessage: aJsonObject [

	aJsonObject type = 'event' ifTrue: [
		aJsonObject event
			caseOf: {
				[#initialized] -> [self sendConfiguration].
				[#output] -> [aJsonObject body category ~= 'telemetry' ifTrue: [self triggerUIEvent: #output with: aJsonObject body]].
				[#terminated] -> [self triggerUIEvent: #terminated].
				[#thread] -> [self triggerUIEvent: #thread].
				[#stopped] -> [self triggerUIEvent: #stopped with: aJsonObject body].
				[#continued] -> [self triggerUIEvent: #continued with: aJsonObject body].
				[#loadedSource] -> []}
			otherwise: [Transcript showln: ('unhandled event: {1}' format: {aJsonObject event})]].
	
	aJsonObject type = 'request' ifTrue: [
		aJsonObject command
			caseOf: {
				[#startDebugging] -> [
					session := SBTSDebugAdapterClient new
						initializeFor: aJsonObject arguments configuration transport: (SBLSPTCPTransport new
							host: transport host;
							port: transport port);
						parent: self.
					self triggerUIEvent: #session with: session]}
			otherwise: [self log: ('unhandled request: {1}' format: {aJsonObject command})]].
	
	aJsonObject type = 'response' ifTrue: [
		pending
			at: aJsonObject request_seq
			ifPresent: [:promise |
				pending removeKey: aJsonObject request_seq.
				aJsonObject success ifFalse: [ | error |
					error := aJsonObject at: 'message' ifAbsent: [(aJsonObject body at: #error) format].
					SBToggledCode comment: '' active: 0 do: {[self onUIThread: [self error: error]]}.
					^ promise rejectWith: error].
				promise resolveWith: aJsonObject body]
			ifAbsent: [self log: {'unknown message'. aJsonObject}]]
]

{ #category : #communication }
SBTSDebugAdapterClient >> initializeFor: aLaunchConfig transport: aTransport [

	transport := aTransport languageClient: self.
	launchConfig := aLaunchConfig.
	
	transport start.
	
	transport connected
		ifTrue: [
			self sendInitializeDo: [
				self launch: launchConfig do: [
					self triggerEvent: #launched.
					self triggerUIEvent: #session with: self]]]
		ifFalse: [self error: 'Could not connect']
]

{ #category : #requests }
SBTSDebugAdapterClient >> launch: arguments do: aBlock [

	self sendRequest: 'launch' params: arguments do: [:res | aBlock value] blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> next: aThreadIdNumber [

	self
		sendRequest: 'next'
		params: (Dictionary newFrom: {'threadId' -> aThreadIdNumber})
		do: [:res | ]
		blocking: false
]

{ #category : #accessing }
SBTSDebugAdapterClient >> parent [

	^ parent
]

{ #category : #accessing }
SBTSDebugAdapterClient >> parent: aSession [

	parent := aSession
]

{ #category : #requests }
SBTSDebugAdapterClient >> pause: aThreadIdNumber [

	self
		sendRequest: 'pause'
		params: (Dictionary newFrom: {'threadId' -> aThreadIdNumber})
		do: [:res | ]
		blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> restartFrame: aFrameNumber [

	self
		sendRequest: 'restartFrame'
		params: (Dictionary newFrom: {'frameId' -> aFrameNumber})
		do: [:res | ]
		blocking: false
]

{ #category : #communication }
SBTSDebugAdapterClient >> sendBlockingResponse: aString to: aNumber params: anObject [

	self internalSend: [:myId | Dictionary newFrom: {#seq -> myId. #'request_seq' -> aNumber. 'type' -> 'response'. 'command' -> aString. 'body' -> anObject}]
]

{ #category : #communication }
SBTSDebugAdapterClient >> sendConfiguration [

	self
		setBreakpoints: {Dictionary newFrom: {'line' -> 6. 'column' -> 7. 'logMessage' -> 'hit! {obj}'}}
		in: '/home/tom/Code/squeak/test.js'.
	
	(serverCapabilities at: #exceptionBreakpointFilters ifAbsent: [#()]) ifNotEmpty: [:filters |
		self
			sendAsyncRequest: 'setExceptionBreakpoints'
			params: (Dictionary newFrom: {'filters' -> (filters collect: [:filter | filter filter])})
			do: [:r | self inform: r]].
	
	^ self sendAsyncRequest: 'configurationDone' params: Dictionary new do: [:res | ]
]

{ #category : #communication }
SBTSDebugAdapterClient >> sendInitializeDo: aBlock [

	initializationPromise := self
		sendRequest: 'initialize'
		params: (Dictionary newFrom: {
			'clientID' -> 'sandblocks'.
			'clientName' -> 'sandblocks'.
			'adapterID' -> 'sandblocks-dap'.
			'pathFormat' -> 'path'.
			'columnsStartAt1' -> true.
			'linesStartAt1' -> true.
			'supportsStartDebuggingRequest' -> true.
			'supportsProgressReporting' -> true.
			'supportsInvalidatedEvent' -> true.
			'supportsValueFormattingOptions' -> true})
		do: [:response |
			serverCapabilities := response.
			aBlock value]
		blocking: false
]

{ #category : #accessing }
SBTSDebugAdapterClient >> session [

	^ session ifNil: [self]
]

{ #category : #requests }
SBTSDebugAdapterClient >> setBreakpoints: aCollection in: aPathString [

	self
		sendRequest: 'setBreakpoints'
		params: (Dictionary newFrom: {'breakpoints' -> aCollection. 'source' -> (Dictionary newFrom: {'path' -> aPathString})})
		do: [:res | ]
		blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> source: aPathString [

	^ self
		sendBlockingRequest: 'source'
		params: (Dictionary newFrom: {'source' -> (Dictionary newFrom: {'path' -> aPathString})})
		do: [:r | r]
]

{ #category : #requests }
SBTSDebugAdapterClient >> stackTraceForThread: aNumber [

	^ self
		sendBlockingRequest: 'stackTrace'
		params: (Dictionary newFrom: {'threadId' -> aNumber})
		do: [:r | r stackFrames]
]

{ #category : #requests }
SBTSDebugAdapterClient >> stepBack: aThreadIdNumber [

	self
		sendRequest: 'stepBack'
		params: (Dictionary newFrom: {'threadId' -> aThreadIdNumber})
		do: [:res | ]
		blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> stepIn: aThreadIdNumber [

	self
		sendRequest: 'stepIn'
		params: (Dictionary newFrom: {'threadId' -> aThreadIdNumber})
		do: [:res | ]
		blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> stepInTargetsIn: aFrameId [

	^ self
		sendBlockingRequest: 'stepInTargets'
		params: (Dictionary newFrom: {'frameId' -> aFrameId})
		do: [:r | r targets]
]

{ #category : #requests }
SBTSDebugAdapterClient >> stepOut: aThreadIdNumber [

	self
		sendRequest: 'stepOut'
		params: (Dictionary newFrom: {'threadId' -> aThreadIdNumber})
		do: [:res | ]
		blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> terminate [

	self sendRequest: 'terminate' params: Dictionary new do: [:res | ] blocking: false
]

{ #category : #requests }
SBTSDebugAdapterClient >> threads [

	^ self sendBlockingRequest: 'threads' params: Dictionary new do: [:r | r threads]
]

{ #category : #helpers }
SBTSDebugAdapterClient >> triggerUIEvent: aSymbol [

	self onUIThread: [self triggerEvent: aSymbol]
]

{ #category : #helpers }
SBTSDebugAdapterClient >> triggerUIEvent: aSymbol with: anObject [

	self onUIThread: [self triggerEvent: aSymbol with: anObject]
]

{ #category : #requests }
SBTSDebugAdapterClient >> variables: aNumber [

	^ self
		sendBlockingRequest: 'variables'
		params: (Dictionary newFrom: {'variablesReference' -> aNumber})
		do: [:r | r variables]
]
