Class {
	#name : #SBTSDebugger,
	#superclass : #SBBlock,
	#instVars : [
		'client',
		'frames',
		'sourceView',
		'pauseContinueButton',
		'paused',
		'currentLocation',
		'output',
		'selectedFrameId'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBTSDebugger >> continued [

	paused := false.
	currentLocation ifNotNil: #detach.
	pauseContinueButton firstSubmorph changeIconName: #iconPause
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> defaultThread [

	^ client threads first id
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> evaluate: aBlock [

	| obj |
	obj := client evaluate: aBlock sourceString in: selectedFrameId.
	^ self resolveVariable: obj maxLevel: 3
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> initialize [

	super initialize.
	
	client := SBTSDebugAdapterClient new
		initializeFor: (Dictionary newFrom: {
			'type' -> 'pwa-node'.
			'stopOnEntry' -> true.
			'program' -> '/home/tom/Code/squeak/test.js'.
			'cwd' -> '/home/tom/Code/squeak'})
		transport: (SBLSPTCPTransport new
			host: 'localhost';
			port: 5678).
	
	paused := false.
	
	client when: #session evaluate: [:session |
		client := session.
		client when: #stopped send: #stopped to: self.
		client when: #continued send: #continued to: self.
		client when: #terminated send: #terminated to: self.
		client when: #output send: #output: to: self].
	
	self
		cellGap: 4;
		hResizing: #rigid;
		vResizing: #rigid;
		layoutInset: 8;
		extent: 300 @ 300;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		listDirection: #topToBottom;
		changeTableLayout;
		addMorphBack: (ScrollPane new
			in: [:s |
				s scroller
					addMorphBack: (frames := SBColumn new hResizing: #spaceFill);
					hResizing: #spaceFill;
					changeTableLayout.
				s];
			hResizing: #spaceFill;
			vResizing: #spaceFill);
		addMorphBack: (SBRow new
			cellGap: 2;
			addMorphBack: (SBButton new icon: SBIcon iconArrowRight do: [client next: self defaultThread]);
			addMorphBack: (SBButton new icon: SBIcon iconArrowDown do: [client stepIn: self defaultThread]);
			addMorphBack: (SBButton new icon: SBIcon iconArrowUp do: [client stepOut: self defaultThread]);
			addMorphBack: (pauseContinueButton := SBButton new
				icon: SBIcon iconPlay
				do: [paused ifTrue: [client continue: self defaultThread] ifFalse: [client pause: self defaultThread]]);
			addMorphBack: (SBButton new icon: SBIcon iconStop do: [client terminate]));
		addMorphBack: (ScrollPane new
			in: [:s |
				sourceView := s scroller.
				s];
			hResizing: #spaceFill;
			vResizing: #spaceFill);
		addMorphBack: (SBStringMorph new
			contents: 'Output:';
			bold);
		addMorphBack: (ScrollPane new
			in: [:s |
				s scroller
					addMorphBack: (output := SBColumn new hResizing: #spaceFill);
					hResizing: #spaceFill;
					changeTableLayout.
				s];
			hResizing: #spaceFill;
			vResizing: #spaceFill)
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	client close
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> output: anObject [

	output addMorphBack: (SBBlock new
		addMorphBack: (SBMultilineOwnTextMorph new contents: anObject output withoutTrailingBlanks);
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		changeTableLayout)
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> reloadArtefact [
	<action>

	self updateAll
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> resolveVariable: aVariable maxLevel: aNumber [

	^ (aVariable variablesReference > 0 and: [aNumber > 0])
		ifTrue: [ | wrapper |
			wrapper := SBTSRemoteObject new
				type: aVariable type;
				value: aVariable value.
			(client variables: aVariable variablesReference) do: [:variable | wrapper at: variable name put: (self resolveVariable: variable maxLevel: aNumber - 1)].
			wrapper]
		ifFalse: [aVariable value]
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> selectFrame: aFrame [

	frames childSandblocks
		detect: [:f | f id = selectedFrameId]
		ifFound: [:f | f detachDecorators: SBHighlightDecorator].
	
	selectedFrameId := aFrame id.
	
	frames childSandblocks
		detect: [:f | f id = selectedFrameId]
		ifFound: [:f | f attachDecorator: SBHighlightDecorator new].
	
	sourceView
		removeAllMorphs;
		addMorphBack: (SBJavascript parse: (client source: aFrame source path) content);
		fullBounds.
	
	sourceView firstSubmorph
		allBlocksDetect: [:b | b range start line + 1 = aFrame line and: [b range start column + 1 = aFrame column]]
		ifFound: [:current |
			currentLocation ifNotNil: #detach.
			current attachDecorator: (currentLocation := SBErrorDecorator new).
			current ensureVisible]
		ifNone: []
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> stopped [

	paused := true.
	pauseContinueButton firstSubmorph changeIconName: #iconPlay.
	self updateAll
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> terminated [

	currentLocation ifNotNil: #detach.
	self submorphs second hide
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> updateAll [

	self updateFrames
]

{ #category : #'as yet unclassified' }
SBTSDebugger >> updateFrames [

	| list |
	frames removeAllMorphs.
	list := client stackTraceForThread: self defaultThread.
	list do: [:frame |
		frames addMorphBack: (SBTSDebuggerFrame new
			for: frame;
			when: #restart send: #restartFrame: to: client;
			when: #selected send: #selectFrame: to: self)].
	
	self selectFrame: (list detect: [:f | f id = selectedFrameId] ifFound: [:f | f] ifNone: [list first])
]
