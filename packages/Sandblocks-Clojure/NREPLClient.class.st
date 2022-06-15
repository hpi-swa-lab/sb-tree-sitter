Class {
	#name : #NREPLClient,
	#superclass : #Object,
	#instVars : [
		'sessionId',
		'port',
		'replProcess',
		'path'
	],
	#category : #'Sandblocks-Clojure'
}

{ #category : #'as yet unclassified' }
NREPLClient >> clone [

	| socket replies |
	socket := self createSocket.
	replies := self send: (Dictionary newFrom: {'op' -> 'clone'}).
	self assert: replies size = 1.
	^ sessionId := replies first at: 'new-session'
]

{ #category : #'as yet unclassified' }
NREPLClient >> close [

	sessionId ifNotNil: [
		self send: (Dictionary newFrom: {'op' -> 'close'. 'session' -> sessionId})]
]

{ #category : #'as yet unclassified' }
NREPLClient >> connectTo: aNumber [

	| socket |
	socket := Socket newTCP.
	[socket connectTo: (NetNameResolver addressFromString: '127.0.0.1') port: aNumber]
		on: ConnectionRefused
		do: [^ nil].
	^ socket
]

{ #category : #'as yet unclassified' }
NREPLClient >> createSocket [

	^ self connectTo: port
]

{ #category : #'as yet unclassified' }
NREPLClient >> eval: aString [

	^ self send: (Dictionary newFrom: {'op' -> 'eval'. 'code' -> aString. 'session' -> self clone})
]

{ #category : #'as yet unclassified' }
NREPLClient >> launchREPLProcess [

	| args outputPipe portAvailable |
	self terminate.
	
	args := {
		'update-in'.
		':dependencies'.
		'conj'.
		'[cljfmt "0.6.7"]'.
		'--'.
		'update-in'.
		':plugins'.
		'conj'.
		'[cider/cider-nrepl "0.24.0"]'.
		'--'.
		'repl'.
		':headless'}.
	outputPipe := OSPipe nonBlockingPipe.
	replProcess := SBToggledCode comment: '' active: 1 do: {
		[
			ExternalUnixOSProcess
				forkAndExec: '/usr/bin/setsid'
				arguments: {'lein'}, args
				environment: nil
				descriptors: {nil. outputPipe writer. nil}
				workingDir: path].
		[
			ExternalUnixOSProcess
				forkAndExec: (SBTSLanguageRuntime which: 'lein')
				arguments: args
				environment: nil
				descriptors: {nil. outputPipe writer. nil}
				workingDir: path]}.
	outputPipe writer close.
	
	portAvailable := Semaphore new.
	
	[
		[outputPipe closed] whileFalse: [ | matches output |
			100 milliSeconds wait.
			output := outputPipe upToEnd.
			output ifNotEmpty: [Transcript show: output].
			matches := 'nrepl\:\/\/.*\:(\d+)' asRegex matchesIn: output.
			matches ifNotEmpty: [
				port := (matches first splitBy: ':') third asNumber.
				portAvailable signal]]] fork.
	
	SBToggledCode comment: '' active: 1 do: {
		[
			portAvailable waitTimeoutMSecs: 10000.
			self clone.
			^ true].
		[ | retries |
			retries := 5.
			[
				(Delay forMilliseconds: 1000) wait.
				(self connectTo: port) ifTrue: [
					self clone.
					^ true].
				retries := retries - 1] doWhileTrue: [retries > 0]]}.
	^ false
]

{ #category : #'as yet unclassified' }
NREPLClient >> lookup: aString [

	| reply replies |
	replies := self send: (Dictionary newFrom: {'op' -> 'lookup'. 'sym' -> aString}).
	self assert: replies size = 1.
	^ (replies first
		at: 'info'
		ifPresent: [:info | info isDictionary ifTrue: [info at: 'doc' ifAbsent: [nil]] ifFalse: [nil]]
		ifAbsent: [nil]) ifNil: [
		reply := self eval: '(doc ', (aString, ')').
		((reply select: [:r | r includesKey: 'out']) collect: [:r | r at: 'out']) joinSeparatedBy: String cr]
]

{ #category : #'as yet unclassified' }
NREPLClient >> path: aString [

	path := aString
]

{ #category : #'as yet unclassified' }
NREPLClient >> port [

	^ port
]

{ #category : #'as yet unclassified' }
NREPLClient >> port: aNumber [

	port := aNumber
]

{ #category : #'as yet unclassified' }
NREPLClient >> send: anObject [

	| socket buffered replies |
	socket := self createSocket.
	socket ifNil: [ConnectionClosed signal: 'repl seems to be gone'].
	
	socket sendData: (String streamContents: [:s | anObject bencodeOn: s]).
	
	buffered := ''.
	replies := OrderedCollection new.
	[ | stream |
		(replProcess ifNotNil: #isComplete ifNil: [false]) ifTrue: [^ self error: 'repl process vanished'].
		20 milliSeconds wait.
		stream := (buffered, socket receiveAvailableData) readStream.
		stream atEnd ifFalse: [replies add: (BencodeDecoder on: stream)].
		buffered := stream upToEnd.
		(replies notEmpty and: [(replies last includesKey: 'status') and: [(replies last at: 'status') includes: 'done']]) ifTrue: [^ replies]] repeat
]

{ #category : #'as yet unclassified' }
NREPLClient >> terminate [

	[self close] on: ConnectionClosed do: [].
	replProcess ifNotNil: #terminate
]
