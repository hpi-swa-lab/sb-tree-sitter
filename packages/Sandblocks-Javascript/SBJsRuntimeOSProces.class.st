Class {
	#name : #SBJsRuntimeOSProces,
	#superclass : #SBTSLanguageRuntime,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProces >> evaluate: aString [

	| outputPipe process node path |
	node := self which: 'node'.
	node ifNil: [^ self error: 'node executable not found'].
	
	path := '/tmp/', (UUID new asString, '.js').
	
	^ [
		FileStream forceNewFileNamed: path do: [:tmpFile | tmpFile nextPutAll: aString].
		outputPipe := OSPipe nonBlockingPipe.
		process := UnixProcess
			forkJob: node
			arguments: {path}
			environment: nil
			descriptors: {nil. outputPipe writer. nil}.
		outputPipe writer close.
		(String streamContents: [:stream |
			[outputPipe atEndOfFile] whileFalse: [
				(Delay forMilliseconds: 20) wait.
				stream nextPutAll: outputPipe upToEnd]]) allButLast] ensure: [FileDirectory deleteFilePath: path]
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProces >> prettyPrint: aString [

	| outputPipe inputPipe process prettier |
	prettier := self which: 'prettier'.
	
	prettier ifNil: [^ aString].
	
	inputPipe := OSPipe blockingPipe.
	outputPipe := OSPipe nonBlockingPipe.
	process := UnixProcess
		forkJob: prettier
		arguments: {'--stdin-filepath'. 'file.js'}
		environment: nil
		descriptors: {inputPipe reader. outputPipe writer. nil}.
	
	inputPipe reader close.
	outputPipe writer close.
	
	inputPipe writer
		nextPutAll: aString utf8Encoded;
		flush;
		close.
	
	^ (String streamContents: [:stream |
		[outputPipe atEndOfFile] whileFalse: [
			(Delay forMilliseconds: 20) wait.
			stream nextPutAll: outputPipe upToEnd]]) allButLast
]

{ #category : #'as yet unclassified' }
SBJsRuntimeOSProces >> which: aString [

	| outputPipe process result |
	outputPipe := OSPipe nonBlockingPipe.
	process := UnixProcess
		forkJob: ExternalUnixOSProcess defaultShellPath
		arguments: {'-c'. 'which {1}' format: {aString}}
		environment: nil
		descriptors: {nil. outputPipe writer. nil}.
	
	outputPipe writer close.
	
	result := String streamContents: [:stream |
		[outputPipe atEndOfFile] whileFalse: [
			(Delay forMilliseconds: 20) wait.
			stream nextPutAll: outputPipe upToEnd]].
	
	^ result ifNotEmpty: #allButLast ifEmpty: [nil]
]
