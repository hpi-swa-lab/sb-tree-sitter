Class {
	#name : #SBJsRuntimeOSProcess,
	#superclass : #SBTSLanguageRuntime,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProcess class >> exampleOpenSocket [

	| socket addr path |
	socket := Socket newTCP: SocketAddressInformation addressFamilyLocal.
	
	addr := ByteArray new: 118.
	path := '/home/tom/tmp/server.sock4' utf8Encoded.
	addr int32At: 1 put: (SocketAddress loopback4 socketAddress int32At: 1).
	addr int32At: 5 put: 110.
	addr int16At: 9 put: 1.
	addr replaceFrom: 11 to: 10 + path size with: path startingAt: 1.
	socket bindTo: addr.
	socket listenWithBacklog: 5.
	
	[
		(socket waitForAcceptFor: 5)
			ifNotNil: [:connectionSocket | | stream |
				stream := SocketStream on: connectionSocket.
				[connectionSocket isConnected] whileTrue: [
					stream peek ifNil: [^ connectionSocket destroy].
					SBWatch report: stream contents for: 670153564]]
			ifNil: [SBWatch report: 'no data' for: 16874667]] ensure: [FileDirectory deleteFilePath: path utf8Decoded]
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProcess >> evaluate: aString [

	| node |
	node := self which: 'node'.
	node ifNil: [^ self error: 'node executable not found'].
	
	^ self
		tmpFile: aString
		do: [:path | self spawnWatchDuring: [:port | self checkedCmd: node arguments: {path} env: {'SQ_WATCH' -> port} stdin: nil]]
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProcess >> prettyPrint: aString [

	| prettier |
	prettier := self which: 'prettier'.
	prettier ifNil: [^ aString].
	
	^ self checkedCmd: prettier arguments: {'--stdin-filepath'. 'file.js'} env: nil stdin: aString
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProcess >> writeWatchSourceOn: aStream watch: aWatch [

	aStream
		nextPutAll: 'require("net").connect(process.env.SQ_WATCH, "localhost").end(JSON.stringify({id:"';
		nextPutAll: aWatch id;
		nextPutAll: '", ';
		nextPutAll: 'expression: '.
	aWatch expression writeSourceOn: aStream.
	aStream nextPutAll: '}))'
]
