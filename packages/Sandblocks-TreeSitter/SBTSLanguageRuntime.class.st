Class {
	#name : #SBTSLanguageRuntime,
	#superclass : #SBBlock,
	#instVars : [
		'factory',
		'root',
		'semantics'
	],
	#category : #'Sandblocks-TreeSitter-Files'
}

{ #category : #accessing }
SBTSLanguageRuntime class >> activateFor: aFile do: aBlock [

	
]

{ #category : #accessing }
SBTSLanguageRuntime class >> available [

	^ true
]

{ #category : #'os process' }
SBTSLanguageRuntime class >> checkedCmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString [

	^ (self cmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString cancel: [:b | ]) wait value: [:status :stdout :stderr |
		status = 0 ifTrue: [stdout] ifFalse: [
			SBTSForeignError new
				contents: stderr;
				source: aProgramPathString;
				signal]]
]

{ #category : #'os process' }
SBTSLanguageRuntime class >> cmd: aProgramPathString arguments: aCollection env: aDictionary in: aWorkingDirString stdin: aString cancel: aBlock pause: anotherBlock [

	| inputPipe outputPipe errorPipe process stderrPromise stdoutPromise processPromise |
	inputPipe := aString ifNotNil: [OSPipe blockingPipe].
	outputPipe := OSPipe nonBlockingPipe.
	errorPipe := OSPipe nonBlockingPipe.
	process := ExternalUnixOSProcess
		forkAndExec: aProgramPathString
		arguments: aCollection
		environment: (aDictionary ifNotNil: [:d | d as: Dictionary])
		descriptors: {
			inputPipe ifNotNil: #reader.
			SBToggledCode comment: '' active: 1 do: {[nil]. [outputPipe writer]}.
			errorPipe writer}
		workingDir: aWorkingDirString.
	aBlock value: [process sigterm].
	anotherBlock value: [:p | p ifTrue: [process sigstop] ifFalse: [process sigcont]].
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

{ #category : #'os process' }
SBTSLanguageRuntime class >> cmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString cancel: aBlock [

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

{ #category : #accessing }
SBTSLanguageRuntime class >> language [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSLanguageRuntime class >> languages [

	^ {self language}
]

{ #category : #accessing }
SBTSLanguageRuntime class >> runtimeName [

	^ self className
]

{ #category : #'os process' }
SBTSLanguageRuntime class >> trimEOF: aString [

	aString ifEmpty: [^ aString].
	aString last = Character lf ifTrue: [^ aString allButLast].
	^ aString
]

{ #category : #'os process' }
SBTSLanguageRuntime class >> which: aString [

	^ (self
		cmd: ExternalUnixOSProcess defaultShellPath
		arguments: {'-c'. 'which {1}' format: {aString}}
		env: OSProcess thisOSProcess environment
		stdin: aString
		cancel: [:b | ]) wait value: [:status :stdout :stderr | status = 0 ifTrue: [stdout ifEmpty: [nil]] ifFalse: [nil]]
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> checkedCmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString [

	^ self class
		checkedCmd: aProgramPathString
		arguments: aCollection
		env: aDictionary
		stdin: aString
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> cmd: aProgramPathString arguments: aCollection env: aDictionary stdin: aString cancel: aBlock [

	^ self class
		cmd: aProgramPathString
		arguments: aCollection
		env: aDictionary
		stdin: aString
		cancel: aBlock
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

{ #category : #semantics }
SBTSLanguageRuntime >> didChange: aFile [

	self semantics didChange: aFile
]

{ #category : #semantics }
SBTSLanguageRuntime >> didClose: aFile [

	self semantics didClose: aFile
]

{ #category : #semantics }
SBTSLanguageRuntime >> didOpen: aFile [

	self semantics didOpen: aFile
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
SBTSLanguageRuntime >> file: aString contents: anotherString do: aBlock [

	^ [
		FileStream forceNewFileNamed: aString do: [:tmpFile | tmpFile nextPutAll: anotherString].
		aBlock value: aString] ensure: [FileDirectory deleteFilePath: aString]
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> handleConnection: aSocket [

	| data env |
	env := SBExecutionEnvironment value.
	data := Json readFrom: (self contentFromSocket: aSocket) readStream.
	
	Project current addDeferredUIMessage: [SBWatch2 reportId: data id value: data expression env: env]
]

{ #category : #'initialize-release' }
SBTSLanguageRuntime >> initialize [

	super initialize.
	
	self
		changeTableLayout;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		cellGap: 4;
		layoutInset: 4;
		addMorphBack: self language iconMorph
]

{ #category : #accessing }
SBTSLanguageRuntime >> language [

	^ self class language
]

{ #category : #'runtime interface' }
SBTSLanguageRuntime >> prettyPrint: aString [

	^ aString
]

{ #category : #'as yet unclassified' }
SBTSLanguageRuntime >> responsibleFor: aBlock [

	| artefact |
	artefact := aBlock containingArtefact.
	^ (artefact respondsTo: #file) and: [self root contains: artefact file]
]

{ #category : #accessing }
SBTSLanguageRuntime >> root [

	^ root
]

{ #category : #accessing }
SBTSLanguageRuntime >> root: aFile [

	root := aFile
]

{ #category : #'as yet unclassified' }
SBTSLanguageRuntime >> semantics [

	^ semantics ifNil: [semantics := self startSemantics]
]

{ #category : #'initialize-release' }
SBTSLanguageRuntime >> shutdown [

	self stopSemantics
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> spawnWatchDuring: aBlock [

	| listener ret env |
	listener := Socket newTCP.
	listener listenOn: 0 backlogSize: 5.
	listener isWaitingForConnection ifFalse: [^ self error: 'Failed to connect'].
	
	env := SBExecutionEnvironment value.
	
	[
		SBExecutionEnvironment value: env.
		[listener isValid] whileTrue: [(listener waitForAcceptFor: 1) ifNotNil: [:connection | self handleConnection: connection]].
		listener destroy]
		forkAt: Processor lowIOPriority
		named: '[SB: watch for expression eval]'.
	
	[ret := aBlock value: listener localPort] ensure: [listener destroy].
	
	^ ret
]

{ #category : #'as yet unclassified' }
SBTSLanguageRuntime >> startSemantics [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBTSLanguageRuntime >> stopSemantics [

	semantics ifNotNil: [:s | s close]
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> tmpFile: aString do: aBlock [

	^ self file: '/tmp/', self tmpFileName contents: aString do: aBlock
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> tmpFileName [

	^ UUID new asString, '.', self factory fileSuffix
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> which: aString [

	^ self class which: aString
]

{ #category : #'helper os process' }
SBTSLanguageRuntime >> writeWatchSourceOn: aStream watch: aWatch [

	self subclassResponsibility
]
