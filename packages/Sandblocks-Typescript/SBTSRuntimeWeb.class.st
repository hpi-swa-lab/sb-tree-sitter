Class {
	#name : #SBTSRuntimeWeb,
	#superclass : #SBTSRuntimeOSProcess,
	#classVars : [
		'WatchServer'
	],
	#category : #'Sandblocks-Typescript'
}

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb class >> runtimeName [

	^ 'web browser'
]

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb class >> watchServer [

	^ WatchServer
]

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb class >> watchServer: aServer [

	WatchServer := aServer
]

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb >> buildWatchSourceFor: aBlock id: aString [

	| watch |
	watch := SBTypescript parseExpression: '((e)=>(fetch(`http://localhost:51234/sqReport?id=${"ID"}&expression=${escape(JSON.stringify(e))}`), e))(expr)'.
	watch childSandblocks second childSandblocks first replaceBlock: aBlock.
	self assert: (watch
		queryRecursiveFirstMatch: '(string_fragment) ="ID" @node'
		capturesDo: [:c | (c at: 'node') contents: aString]).
	^ watch
]

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb >> evaluateFileAsync: aString cancel: aBlock [
	" we cannot actually evaluate the file -- but we can start the watch server "

	self startWatchServer.
	aBlock value: [self stopWatchServer].
	^ Promise new
]

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb >> startWatchServer [

	| server |
	self class watchServer ifNotNil: [:s | s destroy].
	
	server := WebServer new listenOn: 51234.
	server
		addService: '/sqReport'
		action: [:req | | params |
			params := WebUtils decodeUrlEncodedForm: (Url absoluteFromText: req rawUrl) query.
			Project current addDeferredUIMessage: (SBWatch2
				reportId: (params at: 'id')
				value: (params at: 'expression')
				env: SBExecutionEnvironment value).
			req send200Response: 'ok']
		methods: #('GET' 'HEAD').
	self class watchServer: server
]

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb >> stopWatchServer [

	self class watchServer ifNotNil: [:s |
		s destroy.
		self class watchServer: nil]
]

{ #category : #'as yet unclassified' }
SBTSRuntimeWeb >> writeWatchSourceOn: aStream watch: aWatch [

	aStream
		nextPutAll: '((e) => (fetch(`http://localhost:51234/sqReport?id=${"';
		nextPutAll: aWatch id;
		nextPutAll: '"}&expression=${escape(JSON.stringify(e))}`), e))('.
	aWatch expression writeSourceOn: aStream.
	aStream nextPutAll: ')'
]
