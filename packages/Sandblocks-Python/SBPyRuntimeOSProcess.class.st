Class {
	#name : #SBPyRuntimeOSProcess,
	#superclass : #SBTSLanguageRuntime,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> evaluate: aString [

	| python |
	python := self which: 'python'.
	python ifNil: [^ self error: 'python executable not found'].
	
	^ self
		tmpFile: aString
		do: [:path | self spawnWatchDuring: [:port | self checkedCmd: python arguments: {path} env: {'SQ_WATCH' -> port} stdin: nil]]
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> prettyPrint: aString [

	| printer |
	printer := (self which: 'autopep8') ifNil: [^ aString].
	^ self checkedCmd: printer arguments: {'-'} env: nil stdin: aString
]

{ #category : #'as yet unclassified' }
SBPyRuntimeOSProcess >> writeWatchSourceOn: aStream watch: aWatch [

	aStream
		nextPutAll: 'print(
        (lambda e:
            ((lambda s: (s.connect(("localhost", int(__import__("os").environ["SQ_WATCH"]))), s.send(("{\"id\":\"';
		nextPutAll: aWatch id;
		nextPutAll: '\",\"expression\":"+str(e)+"}").encode()), s.close()))(__import__("socket").socket()), e))('.
	aWatch expression writeSourceOn: aStream.
	aStream nextPutAll: ')[1])'
]
