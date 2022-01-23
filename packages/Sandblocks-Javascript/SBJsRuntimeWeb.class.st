Class {
	#name : #SBJsRuntimeWeb,
	#superclass : #SBJsRuntimeOSProcess,
	#classVars : [
		'WatchServer'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRuntimeWeb class >> runtimeName [

	^ 'web browser'
]

{ #category : #'as yet unclassified' }
SBJsRuntimeWeb class >> watchServer [

	^ WatchServer
]

{ #category : #'as yet unclassified' }
SBJsRuntimeWeb class >> watchServer: aServer [

	WatchServer := aServer
]

{ #category : #'as yet unclassified' }
SBJsRuntimeWeb >> evaluateFileAsync: aString cancel: aBlock [
	" we cannot actually evaluate the file -- but we can start the watch server "

	self startWatchServer.
	aBlock value: [self stopWatchServer].
	^ Promise new
]

{ #category : #'as yet unclassified' }
SBJsRuntimeWeb >> startWatchServer [

	| server |
	self class watchServer ifNotNil: [:s | s destroy].
	
	server := WebServer new listenOn: 51234.
	server
		addService: '/sqReport'
		action: [:req | | params |
			params := WebUtils decodeUrlEncodedForm: (Url absoluteFromText: req rawUrl) query.
			SBTSWatch
				reportId: (params at: 'id')
				value: (params at: 'expression')
				env: SBExecutionEnvironment value.
			req send200Response: 'ok']
		methods: #('GET' 'HEAD').
	self class watchServer: server
]

{ #category : #'as yet unclassified' }
SBJsRuntimeWeb >> stopWatchServer [

	self class watchServer ifNotNil: [:s |
		s destroy.
		self class watchServer: nil]
]

{ #category : #'as yet unclassified' }
SBJsRuntimeWeb >> writeWatchSourceOn: aStream watch: aWatch [

	aStream
		nextPutAll: '((e) => (fetch(`http://localhost:51234/sqReport?id=${"';
		nextPutAll: aWatch id;
		nextPutAll: '"}&expression=${escape(JSON.stringify(e))}`), e))('.
	aWatch expression writeSourceOn: aStream.
	aStream nextPutAll: ')'
]
