Class {
	#name : #SBTSLanguageRuntime,
	#superclass : #Object,
	#instVars : [
		'factory'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'helper os process' }
SBTSLanguageRuntime >> checkedCmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString [

	^ (self cmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString cancel: [:b | ]) wait value: [:status :stdout :stderr | status = 0 ifTrue: [stdout] ifFalse: [self error: stderr]]
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> cmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString cancel: aBlock [

	| inputPipe outputPipe errorPipe process stderrPromise stdoutPromise processPromise |
	inputPipe := aString ifNotNil: [OSPipe blockingPipe].
	outputPipe := OSPipe nonBlockingPipe.
	errorPipe := OSPipe nonBlockingPipe.
	process := UnixProcess
		forkJob: aProgramPathString
		arguments: aCollection
		environment: (aDictionary ifNotNil: [:d | d as: Dictionary])
		descriptors: {inputPipe ifNotNil: #reader. outputPipe writer. errorPipe writer}.
	aBlock value: [process sigterm].
	outputPipe writer close.
	errorPipe writer close.
	inputPipe ifNotNil: [
		inputPipe reader close.
		inputPipe writer
			nextPutAll: aString utf8Encoded;
			flush;
			close].
	
	processPromise := Promise new.
	stdoutPromise := Promise new.
	stderrPromise := Promise new.
	[
		stdoutPromise resolveWith: (self trimEOF: (String streamContents: [:stream |
			[outputPipe closed] whileFalse: [
				(Delay forMilliseconds: 20) wait.
				stream nextPutAll: outputPipe upToEnd]]))] fork.
	[
		stderrPromise resolveWith: (self trimEOF: (String streamContents: [:stream |
			[errorPipe closed] whileFalse: [
				(Delay forMilliseconds: 20) wait.
				stream nextPutAll: errorPipe upToEnd]]))] fork.
	[
		[process runState == #complete] whileFalse: [(Delay forMilliseconds: 20) wait].
		outputPipe close.
		errorPipe close.
		processPromise resolveWith: (UnixProcessExitStatus for: process exitStatus) exitStatus] fork.
	
	^ (Promise all: {processPromise. stdoutPromise. stderrPromise}) then: [:array | [:block | block valueWithArguments: array]]
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> contentFromSocket: aSocket [

	| stream data |
	stream := SocketStream on: aSocket.
	stream timeout: 1.
	data := stream upToEnd.
	aSocket close.
	stream close.
	^ data
]

{ #category : #'runtime interface' }
SBTSLanguageRuntime >> evaluate: aString [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSLanguageRuntime >> factory [

	^ factory
]

{ #category : #accessing }
SBTSLanguageRuntime >> factory: aFactory [

	factory := aFactory
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> handleConnection: aSocket [

	| data |
	data := Json readFrom: (self contentFromSocket: aSocket) readStream.
	
	Project current addDeferredUIMessage: [SBTSWatch reportId: data id value: data expression]
]

{ #category : #'runtime interface' }
SBTSLanguageRuntime >> prettyPrint: aString [

	^ self subclassResponsibility
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> spawnWatchDuring: aBlock [

	| listener ret |
	listener := Socket newTCP.
	listener listenOn: 0 backlogSize: 5.
	listener isWaitingForConnection ifFalse: [^ self error: 'Failed to connect'].
	
	[
		[listener isValid] whileTrue: [(listener waitForAcceptFor: 1) ifNotNil: [:connection | self handleConnection: connection]].
		listener destroy]
		forkAt: Processor lowIOPriority
		named: '[SB: watch for expression eval]'.
	
	[ret := aBlock value: listener localPort] ensure: [listener destroy].
	
	^ ret
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> tmpFile: aString do: aBlock [

	| path |
	path := '/tmp/', (UUID new asString, '.', self factory class fileSuffix).
	^ [
		FileStream forceNewFileNamed: path do: [:tmpFile | tmpFile nextPutAll: aString].
		aBlock value: path] ensure: [FileDirectory deleteFilePath: path]
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> trimEOF: aString [

	aString ifEmpty: [^ aString].
	aString last = Character lf ifTrue: [^ aString allButLast].
	^ aString
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> which: aString [

	^ self
		checkedCmd: ExternalUnixOSProcess defaultShellPath
		arguments: {'-c'. 'which {1}' format: {aString}}
		env: nil
		stdin: nil
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> writeWatchSourceOn: aStream watch: aWatch [

	self subclassResponsibility
]
