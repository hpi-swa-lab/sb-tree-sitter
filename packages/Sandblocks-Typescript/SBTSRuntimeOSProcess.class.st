Class {
	#name : #SBTSRuntimeOSProcess,
	#superclass : #SBTSLanguageRuntime,
	#classInstVars : [
		'root'
	],
	#category : #'Sandblocks-Typescript'
}

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess class >> activateFor: aFile do: aBlock [

	aFile children
		detect: [:file | file basename = 'tsconfig.json']
		ifFound: [:f | aBlock value: (self new root: aFile)]
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess class >> language [

	^ SBTypescript
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess class >> languages [

	^ {SBTypescript. SBTSX}
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess class >> runtimeName [

	^ 'node.js/ts-node'
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess >> buildWatchSourceFor: aBlock id: aString [

	| watch |
	self
		example: [SBTSRuntimeOSProcess new]
		args: [{SBTypescript parseExpression: '3'. 'myid'}]
		label: 'example'.
	watch := SBTypescript parseExpression: '((e) => (require("net").connect(process.env.SQ_WATCH, "localhost").end(JSON.stringify({id:"ID",expression: require("util").inspect(e)})), e))(expr)'.
	watch childSandblocks second childSandblocks first replaceBlock: aBlock.
	self assert: (watch
		queryRecursiveFirstMatch: '(string_fragment) ="ID" @node'
		capturesDo: [:c | (c at: 'node') contents: aString]).
	^ watch
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess >> evaluate: aString [

	| npx |
	npx := self which: 'npx'.
	npx ifNil: [^ self error: 'node executable not found'].
	
	^ self
		tmpFile: aString
		do: [:path | self spawnWatchDuring: [:port | self checkedCmd: npx arguments: {'ts-node'. path} env: {'SQ_WATCH' -> port} stdin: nil]]
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess >> evaluateFileAsync: aString cancel: aBlock [

	| npx ret |
	npx := self which: 'npx'.
	npx ifNil: [^ self error: 'node executable not found'].
	
	ret := Promise new.
	[
		self spawnWatchDuring: [:port |
			ret resolveWith: (self
				cmd: npx
				arguments: {'ts-node'. aString}
				env: OSProcess thisOSProcess environment, {'SQ_WATCH' -> port}
				stdin: nil
				cancel: aBlock) wait]] fork.
	^ ret
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess >> prettyPrint: aString [

	| prettier |
	SBToggledCode comment: '' active: 1 do: {[^ aString]}.
	
	prettier := self which: 'prettier'.
	prettier ifNil: [^ aString].
	
	^ self checkedCmd: prettier arguments: {'--stdin-filepath'. 'file.ts'} env: nil stdin: aString
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess >> root [

	^ root
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess >> root: aFile [

	root := aFile
]

{ #category : #'as yet unclassified' }
SBTSRuntimeOSProcess >> startSemantics [

	^ SBTSLSPSemantics new
		on: self root
		transport: (SBLSPStdioTransport new
			command: (SBTSLanguageRuntime which: 'typescript-language-server');
			arguments: {'--stdio'};
			workingDirectory: self root asString)
		onReady: []
]
