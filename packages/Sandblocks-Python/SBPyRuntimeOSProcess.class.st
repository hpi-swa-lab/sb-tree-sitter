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

	self pythonPath: (UIManager default
		request: 'Path to python executable?'
		initialAnswer: (self pythonPath ifNil: [self which: 'python3'])).
	^ self pythonPath
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
SBPyRuntimeOSProcess >> prettyPrint: aString [

	| printer args |
	args := #().
	printer := nil.
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

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> writeWatchSourceOn: aStream watch: aWatch [

	aStream
		nextPutAll: '(lambda e:
            ((lambda s: (s.connect(("localhost", int(__import__("os").environ["SQ_WATCH"]))), s.send(("{\"id\":\"';
		nextPutAll: aWatch id;
		nextPutAll: '\",\"expression\":\""+str(e)+"\"}").encode()), s.close()))(__import__("socket").socket()), e))('.
	aWatch expression writeSourceOn: aStream.
	aStream nextPutAll: ')[1]'
]
