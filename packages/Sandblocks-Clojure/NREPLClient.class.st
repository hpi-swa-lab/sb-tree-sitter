Class {
	#name : #NREPLClient,
	#superclass : #Object,
	#instVars : [
		'socket',
		'sessionId',
		'port',
		'replProcess',
		'path'
	],
	#category : #'Sandblocks-Clojure'
}

{ #category : #'as yet unclassified' }
NREPLClient >> clone [

	| reply |
	self send: (Dictionary newFrom: {'op' -> 'clone'}).
	reply := BencodeDecoder on: socket receiveData readStream.
	sessionId := reply at: 'new-session'
]

{ #category : #'as yet unclassified' }
NREPLClient >> close [

	sessionId ifNotNil: [
		self send: (Dictionary newFrom: {'op' -> 'close'. 'session' -> sessionId})]
]

{ #category : #'as yet unclassified' }
NREPLClient >> connectTo: aNumber [

	socket := Socket newTCP.
	[socket connectTo: (NetNameResolver addressFromString: '127.0.0.1') port: aNumber] on: ConnectionRefused do: [^ false].
	^ true
]

{ #category : #'as yet unclassified' }
NREPLClient >> eval: aString [

	self send: (Dictionary newFrom: {'op' -> 'eval'. 'code' -> aString. 'session' -> sessionId}).
	^ Array streamContents: [:s |  | reply |[s nextPut: (reply := BencodeDecoder on: socket receiveData readStream)] doWhileFalse: [(reply includesKey: 'value') or: [(reply includesKey: 'ex') or: [reply includesKey: 'root-ex']]]]
]

{ #category : #'as yet unclassified' }
NREPLClient >> launchREPLProcess [

	| retries |
	port := (1024 to: 2 ** 16 - 1) atRandom.
	
	replProcess := ExternalUnixOSProcess
		forkAndExec: (SBTSLanguageRuntime which: 'lein')
		arguments: {'repl'. ':start'. ':port'. port asString}
		environment: nil
		descriptors: nil
		workingDir: path.
	retries := 500.
	[
		(Delay forMilliseconds: 200) wait.
		(self connectTo: port) ifTrue: [
			self clone.
			^ true].
		retries := retries - 1] doWhileTrue: [retries > 0].
	^ false
]

{ #category : #'as yet unclassified' }
NREPLClient >> lookup: aString [

	| reply |
	self send: (Dictionary newFrom: {'op' -> 'lookup'. 'sym' -> aString}).
	reply := BencodeDecoder on: socket receiveData readStream.
	^ (reply
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
NREPLClient >> send: anObject [

	socket sendData: (String streamContents: [:s | anObject bencodeOn: s])
]

{ #category : #'as yet unclassified' }
NREPLClient >> terminate [

	[self close] on: ConnectionTimedOut do: [].
	socket ifNotNil: #close.
	replProcess ifNotNil: #terminate
]
