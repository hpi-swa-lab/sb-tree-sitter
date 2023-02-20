Class {
	#name : #SBLSPTCPTransport,
	#superclass : #SBLSPTransport,
	#instVars : [
		'socket',
		'host',
		'port',
		'stream'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBLSPTCPTransport >> handleDataFrom: aStream [

	| length message data |
	[aStream upToAll: 'Content-Length: ']
		on: SocketPrimitiveFailed
		do: [:e | ^ self].
	
	length := (aStream upToAll: String crlfcrlf) asNumber.
	data := (aStream next: length) utf8ToSqueak.
	message := Json readFrom: data readStream.
	languageClient log: {'>'. data}.
	languageClient handleMessage: message
]

{ #category : #'as yet unclassified' }
SBLSPTCPTransport >> host: aString [

	host := aString
]

{ #category : #'as yet unclassified' }
SBLSPTCPTransport >> port: aNumber [

	port := aNumber
]

{ #category : #'as yet unclassified' }
SBLSPTCPTransport >> start [

	super start.
	
	socket := Socket newTCP.
	socket connectTo: (NetNameResolver addressFromString: '127.0.0.1') port: port.
	stream := SocketStream on: socket.
	stream timeout: 100000.
	
	[[stream atEnd] whileFalse: [self handleDataFrom: stream]] fork
]

{ #category : #'as yet unclassified' }
SBLSPTCPTransport >> stop [

	[stream close] on: Error do: [:error | ].
	[socket close] on: Error do: [:error | ]
]

{ #category : #'as yet unclassified' }
SBLSPTCPTransport >> writer [

	^ stream
]
