Class {
	#name : #NREPLClient,
	#superclass : #Object,
	#instVars : [
		'socket',
		'sessionId'
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

	self send: (Dictionary newFrom: {'op' -> 'close'. 'session' -> sessionId})
]

{ #category : #'as yet unclassified' }
NREPLClient >> eval: aString [

	self send: (Dictionary newFrom: {'op' -> 'eval'. 'code' -> aString. 'session' -> sessionId}).
	^ Array streamContents: [:s |  | reply |[s nextPut: (reply := BencodeDecoder on: socket receiveData readStream)] doWhileFalse: [(reply includesKey: 'value') or: [(reply includesKey: 'ex') or: [reply includesKey: 'root-ex']]]]
]

{ #category : #'as yet unclassified' }
NREPLClient >> initialize [

	super initialize.
	
	socket := Socket newTCP.
	socket connectTo: (NetNameResolver addressFromString: '127.0.0.1') port: (UIManager default request: 'port?') asInteger
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
		"using odoc from overtone here... should be part of separate runtime"
		self flag: #fixme.
		reply := self eval: '(odoc ', (aString, ')').
		((reply select: [:r | r includesKey: 'out']) collect: [:r | r at: 'out']) joinSeparatedBy: String cr]
]

{ #category : #'as yet unclassified' }
NREPLClient >> send: anObject [

	socket sendData: (String streamContents: [:s | anObject bencodeOn: s])
]

{ #category : #'as yet unclassified' }
NREPLClient >> terminate [

	[self close] on: ConnectionTimedOut do: [].
	socket close
]
