Class {
	#name : #SBLSPTransport,
	#superclass : #Object,
	#instVars : [
		'buffer',
		'languageClient'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBLSPTransport >> handleData [

	| length message data readBuffer |
	readBuffer := buffer readStream.
	(readBuffer nextMatchAll: 'Content-Length: ') ifFalse: [^ false].
	(readBuffer peekDuring: [readBuffer skipTo: Character cr]) ifFalse: [^ false].
	length := (readBuffer upTo: Character cr) asNumber.
	(readBuffer nextMatchAll: String lf, String crlf) ifFalse: [^ false].
	data := readBuffer next: length.
	data size ~= length ifTrue: [^ false].
	message := Json readFrom: data utf8ToSqueak readStream.
	languageClient log: {'>'. message}.
	languageClient handleMessage: message.
	buffer := readBuffer upToEnd.
	^ true
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> languageClient: aClient [

	languageClient := aClient
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> readFrom: aString [

	buffer := buffer, aString.
	[self handleData] whileTrue.
	20 milliSeconds wait
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> restart [

	self stop.
	self start
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> send: aJsonObject [

	| payload |
	languageClient log: {'<'. aJsonObject}.
	
	payload := aJsonObject asJsonString utf8Encoded.
	self writer
		nextPutAll: 'Content-Length: ';
		nextPutAll: payload size asString;
		nextPutAll: String crlfcrlf;
		nextPutAll: payload;
		flush
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> start [

	buffer := ''
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> stop [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> writer [

	^ self subclassResponsibility
]
