Class {
	#name : #SBGodotRuntime,
	#superclass : #SBTSLanguageRuntime,
	#category : #'Sandblocks-GDScript'
}

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
