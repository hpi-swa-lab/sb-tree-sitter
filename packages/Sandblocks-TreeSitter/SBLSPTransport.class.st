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
SBLSPTransport >> connected [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBLSPTransport >> handleData [

	| readBuffer header headers continue length data message |
	readBuffer := buffer readStream.
	buffer ifEmpty: [^ false].
	
	headers := Dictionary new.
	continue := true.
	[
		header := readBuffer upToAll: String crlf.
		readBuffer last = Character lf ifFalse: [^ false].
		header isEmpty
			ifFalse: [ | parts |
				parts := header splitBy: ': '.
				headers at: parts first asLowercase put: parts second]
			ifTrue: [continue := false]] doWhileTrue: [continue].
	length := (headers at: 'content-length' ifAbsent: [^ false]) asNumber.
	data := readBuffer next: length.
	data size = length ifFalse: [^ false].
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
