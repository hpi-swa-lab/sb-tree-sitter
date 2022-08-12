Class {
	#name : #SBPyRuntimeOSProcess,
	#superclass : #SBTSLanguageRuntime,
	#classVars : [
		'PythonPath'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess class >> defaultPythonPath [

	^ (self pythonPath ifNil: [self which: 'python3']) ifNil: [self selectPath]
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess class >> language [

	^ SBPython
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess class >> pythonPath [

	^ PythonPath
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess class >> pythonPath: aString [

	PythonPath := aString
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess class >> runtimeName [

	^ 'python interpreter'
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess class >> selectPath [
	<action>

	| path |
	path := UIManager default
		request: 'Path to python executable?'
		initialAnswer: (self pythonPath ifNil: [(self which: 'python3') ifNil: ['']]).
	self pythonPath: (path ifEmpty: [nil]).
	^ self pythonPath
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> buildWatchSourceFor: aBlock id: aString [

	| watch |
	self
		example: [SBPyRuntimeOSProcess new]
		args: [{SBPython parseExpression: '3'. 'myid'}]
		label: 'example'.
	watch := SBPython parseExpression: '(lambda e:
            ((lambda s: (s.connect(("localhost", int(__import__("os").environ["SQ_WATCH"]))), s.send(("PAYLOAD_START"+str(e)+"\"}").encode()), s.close()))(__import__("socket").socket()), e))(e)[1]'.
	watch childSandblocks first childSandblocks second childSandblocks first replaceBlock: aBlock.
	self assert: (watch
		queryRecursiveFirstMatch: '(string) ="PAYLOAD_START" @node'
		capturesDo: [:c | (c at: 'node') contents: '{\"id\":\"', aString, '\",\"expression\":\"']).
	^ watch
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> evaluate: aString [

	| python |
	python := self class defaultPythonPath ifNil: [^ nil].
	
	^ self
		tmpFile: aString
		do: [:path | self spawnWatchDuring: [:port | self checkedCmd: python arguments: {path} env: {'SQ_WATCH' -> port} stdin: nil]]
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> evaluateFileAsync: aString cancel: aBlock [

	| python ret |
	python := self class defaultPythonPath ifNil: [^ nil].
	
	ret := Promise new.
	[self spawnWatchDuring: [:port | ret resolveWith: (self cmd: python arguments: {aString} env: {'SQ_WATCH' -> port} stdin: nil cancel: aBlock) wait]] fork.
	^ ret
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> evaluateModuleAsync: aString in: aPath args: aCollection cancel: aBlock pause: anotherBlock [

	| python ret env |
	python := self interpreter ifNil: [^ nil].
	
	env := SBExecutionEnvironment value.
	
	ret := Promise new.
	[
		SBExecutionEnvironment value: env.
		self spawnWatchDuring: [:port |
			ret resolveWith: (self class
				cmd: python
				arguments: {'-m'. aString}, aCollection
				env: {'SQ_WATCH' -> port}
				in: aPath
				stdin: nil
				cancel: aBlock
				pause: anotherBlock) wait]] fork.
	^ ret
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> interpreter [

	^ self class defaultPythonPath
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> prettyPrint: aString [

	| printer args |
	SBToggledCode comment: '' active: 1 do: {[^ aString]}.
	args := #().
	printer := nil.
	printer ifNil: [
		(self which: 'black') ifNotNil: [:path |
			printer := path.
			args := #('-q' '-')]].
	printer ifNil: [(self which: 'yapf3') ifNotNil: [:path | printer := path]].
	printer ifNil: [(self which: 'yapf') ifNotNil: [:path | printer := path]].
	printer ifNil: [
		(self which: 'autopep8') ifNotNil: [:path |
			printer := path.
			args := #('-')]].
	printer ifNil: [^ aString].
	
	^ self checkedCmd: printer arguments: args env: nil stdin: aString withUnixLineEndings
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> selectPath [
	<action>

	self class pythonPath: (UIManager default
		request: 'Path to python executable?'
		initialAnswer: (self class pythonPath ifNil: [self which: 'python3']))
]
