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
SBJsRuntimeOSProcess class >> language [

	^ SBJavascript
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProcess class >> runtimeName [

	^ 'node.js'
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProcess >> buildWatchSourceFor: aBlock id: aString [

	| watch |
	self
		example: [SBJsRuntimeOSProcess new]
		args: [{SBJavascript parseExpression: '3'. 'myid'}]
		label: 'example'.
	watch := SBJavascript parseExpression: '((e) => (require("net").connect(process.env.SQ_WATCH, "localhost").end(JSON.stringify({id:"ID",expression: require("util").inspect(e)})), e))(expr)'.
	watch childSandblocks second replaceBlock: aBlock.
	self assert: (watch
		queryRecursiveFirstMatch: '(string_fragment) ="ID" @node'
		capturesDo: [:c | (c at: 'node') contents: aString]).
	^ watch
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
SBJsRuntimeOSProcess >> evaluateFileAsync: aString cancel: aBlock [

	| node ret |
	node := self which: 'node'.
	node ifNil: [^ self error: 'node executable not found'].
	
	ret := Promise new.
	[self spawnWatchDuring: [:port | ret resolveWith: (self cmd: node arguments: {aString} env: {'SQ_WATCH' -> port} stdin: nil cancel: aBlock) wait]] fork.
	^ ret
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProcess >> prettyPrint: aString [

	| prettier |
	SBToggledCode comment: '' active: 1 do: {[^ aString]}.
	
	prettier := self which: 'prettier'.
	prettier ifNil: [^ aString].
	
	^ self checkedCmd: prettier arguments: {'--stdin-filepath'. 'file.js'} env: nil stdin: aString
]
