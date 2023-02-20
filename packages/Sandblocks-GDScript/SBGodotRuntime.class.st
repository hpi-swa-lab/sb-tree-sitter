Class {
	#name : #SBGodotRuntime,
	#superclass : #SBTSLanguageRuntime,
	#instVars : [
		'watchListener'
	],
	#category : #'Sandblocks-GDScript'
}

{ #category : #'as yet unclassified' }
SBGodotRuntime class >> activateFor: aFile do: aBlock [

	aFile children
		detect: [:file | file basename = 'project.godot']
		ifFound: [:f | aBlock value: (self new root: aFile)]
]

{ #category : #'as yet unclassified' }
SBGodotRuntime class >> language [

	^ SBGDScript
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> buildWatchSourceFor: aBlock id: aString [

	| watch |
	self
		example: [SBGodotRuntime new]
		args: [{(SBGDScript parseExpression: '3') childSandblocks first. 'myid'}]
		label: 'example'.
	"class Sq:
	var tcp
	static func sqSend(obj, id):
		if not tcp:
			tcp = StreamPeerTCP.new()
			tcp.connect_to_host('127.0.0.1', int(OS.get_environment('SQ_WATCH'))
		tcp.put_string(JSON.print({'id': id, 'expression': obj})"
	watch := (SBGDScript parseExpression: 'Sq.sqSend(e,"ID")') childSandblocks first.
	(watch queryNode: '(identifier) @') replaceBlock: aBlock.
	(watch queryNode: '(string) @') contents: aString.
	^ watch
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> handleWatchConnection: aSocket [

	| data |
	'"echo "{\"openFile\":\"$1\",\"line\":$2,\"col\":$3}" | nc localhost 11887 -N"; wmctrl -a Squeak'.
	
	data := Json readFrom: (self contentFromSocket: aSocket) readStream.
	
	^ Project current addDeferredUIMessage: [
		(data includesKey: #openFile)
			ifTrue: [
				self sandblockEditor openFile: data openFile asReference.
				self sandblockEditor containingWindow beKeyWindow]
			ifFalse: [SBWatch2 reportId: data id value: data expression env: nil]]
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> responsibleFor: aBlock [

	^ (super responsibleFor: aBlock) and: [aBlock containingArtefact file extension = 'gd']
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> root: aFile [

	super root: aFile.
	
	watchListener := Socket newTCP.
	watchListener listenOn: self watchPort backlogSize: 5.
	watchListener isWaitingForConnection ifFalse: [^ self error: 'Failed to connect'].
	
	[
		[watchListener isValid] whileTrue: [(watchListener waitForAcceptFor: 1) ifNotNil: [:connection | self handleWatchConnection: connection]].
		watchListener destroy]
		forkAt: Processor lowIOPriority
		named: '[Godot Watch Listener]'
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> shutdown [

	super shutdown.
	
	watchListener ifNotNil: #destroy
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> startProject: aPathString godotPath: aGodotPath cancel: aBlock [

	| ret |
	ret := Promise new.
	[
		self spawnWatchDuring: [:port |
			ret resolveWith: (self class
				cmd: aGodotPath
				arguments: {}
				env: (UnixProcess env copy
					at: 'SQ_WATCH' put: port;
					yourself)
				in: aPathString
				stdin: nil
				cancel: aBlock
				pause: [:p | ]) wait]] fork.
	^ ret
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> startSemantics [

	^ SBTSLSPSemantics new
		on: self root
		transport: (SBLSPTCPTransport new
			host: '127.0.0.1';
			port: 6008)
		onReady: []
]

{ #category : #'as yet unclassified' }
SBGodotRuntime >> watchPort [

	^ 11887
]
