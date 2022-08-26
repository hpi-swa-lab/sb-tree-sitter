Class {
	#name : #SBExperimentEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'server',
		'times',
		'keyListenerProcess',
		'outputPipe'
	],
	#category : #'Sandblocks-TreeSitter-Tutorial'
}

{ #category : #'as yet unclassified' }
SBExperimentEditor class >> openFor: aString language: aLanguage [

	| editor |
	editor := self new.
	editor openMorphInView: (aLanguage parseToplevel: aString).
	editor openInWindow.
	^ editor
]

{ #category : #'as yet unclassified' }
SBExperimentEditor class >> openTutorial [

	| editor |
	editor := self new.
	SBTSTutorial openIn: editor.
	editor openInWindow.
	^ editor
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> clearTimes [
	<globalAction>

	times := OrderedCollection new
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> collectingKeys [

	^ keyListenerProcess notNil
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> copyData [
	<globalAction>

	| demographics |
	demographics := times detect: [:entry | entry mode = 'demographics'].
	Clipboard clipboardText: (((0 to: 3) gather: [:taskIndex | | relevant sandblocks text |
		relevant := times select: [:entry | entry taskName notNil and: [entry taskName startsWith: 'task0', taskIndex]].
		sandblocks := relevant select: [:entry | entry editor = 'sb'].
		text := relevant select: [:entry | entry editor = 'text'].
		
		{sandblocks. text} collect: [:data | | complete start scores firstKey lastKey |
			start := data detect: [:entry | entry event = 'start'].
			complete := data detect: [:entry | entry event = 'complete' and: [entry mode = 'task']].
			firstKey := (((complete at: #keys) at: #keys)
				detect: [:key | (key first beginsWith: 'CLICK') not]
				ifNone: [{0. 0}]) second.
			lastKey := (((complete at: #keys) at: #keys) reversed
				detect: [:key | (key first beginsWith: 'CLICK') not]
				ifNone: [{0. 0}]) second.
			
			scores := data detect: [:entry | entry event = 'scores'].
			{lastKey - firstKey}, (complete at: #keys) counts, scores scores, {((complete at: #keys) at: #keys) asJsonString}]]) flatten, (demographics at: #values) joinSeparatedBy: String tab)
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> currentCode [

	| code |
	code := nil.
	Project current addDeferredUIMessage: [code := (self childSandblocks detect: [:c | c isTSBlock]) sourceString withUnixLineEndings].
	World doOneCycleNow.
	self assert: code notNil.
	^ code
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> initialize [

	super initialize.
	
	scroll scroller layoutInset: (SBEdgeInsets left: 150 right: 150 top: 0 bottom: 0)
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> insertEmptyCommandRequestNear: aMorph before: aBlock [

	^ nil
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> intoWorld: aWorld [

	| setHeaders |
	super intoWorld: aWorld.
	setHeaders := [:res |
		res headerAt: 'Content-Type' put: 'application/json'.
		res headerAt: 'Access-Control-Allow-Origin' put: '*'.
		res headerAt: 'Access-Control-Allow-Headers' put: '*'.
		res headerAt: 'Access-Control-Allow-Methods' put: '*'].
	Transcript showln: 'hello'.
	server := WebServer new
		listenOn: 8000;
		errorHandler: [:ex :req |
			Transcript showln: ex.
			req sendResponseCode: 500 content: 'internal error' type: 'text/plain' do: setHeaders.
			ex signal];
		yourself.
	times := OrderedCollection new.
	server addService: '/report' action: [:req | | data raw |
		req method = 'OPTIONS'
			ifTrue: [req send200Response: 'application/json' contentType: 'text/plain; charset=utf-8' do: setHeaders]
			ifFalse: [
				raw := req getContent.
				data := Json readFrom: raw readStream.
				data event = 'start' ifTrue: [self startCollectKeys].
				(data event = 'complete' and: [self collectingKeys]) ifTrue: [data at: 'keys' put: self stopCollectKeys].
				(data event = 'complete' and: [data editor = 'sb' and: [data mode = 'task']]) ifTrue: [data at: 'code' put: self currentCode].
				
				times add: data.
				FileStream fileNamed: ('experiment-{1}.jsonl' format: {data at: 'runNumber'}) do: [:stream |
					stream
						setToEnd;
						nextPutAll: raw;
						cr;
						flush].
				req send200Response: '' contentType: 'text/plain; charset=utf-8' do: setHeaders]].
	server addService: '/code' action: [:req |
		req method caseOf: {
			['OPTIONS'] -> [req send200Response: '' contentType: 'text/plain; charset=utf-8' do: setHeaders].
			['GET'] -> [
				Transcript showln: 'open code'.
				req
					send200Response: ({'code' -> self currentCode} as: Dictionary) asJsonString
					contentType: 'application/json'
					do: setHeaders].
			['POST'] -> [ | code data language |
				data := Json readFrom: req getContent readStream.
				code := data code.
				language := SBTSFile languageForPath: data taskName.
				Project current addDeferredUIMessage: [
					code
						ifEmpty: [
							SBTutorialStep resetAllProgress.
							SBTSPyTutorial openIn: self]
						ifNotEmpty: [ | block |
							block := language parseToplevel: code.
							self openMorphInView: block.
							(data taskName beginsWith: 'task03') ifTrue: [block applyReplacements]]].
				req send200Response: '{}' contentType: 'application/json' do: setHeaders]}]
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	Smalltalk platformName ~= 'Win32' ifTrue: [keyListenerProcess ifNotNil: [keyListenerProcess terminate]].
	server destroy
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> python [

	self openMorphInView: (SBPython parseToplevel: SBTSReconstructExperiment basicNew pythonFlaskBlueprints)
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> server [

	^ server
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> startCollectKeys [

	Smalltalk platformName = 'Win32' ifTrue: [
		keyListenerProcess := ExternalWindowsOSProcess command: ('python {1}\\key-count.py' format: {FileDirectory default fullName}).
		^ self].
	
	outputPipe := OSPipe nonBlockingPipe.
	keyListenerProcess := ExternalUnixOSProcess
		forkAndExec: (SBTSLanguageRuntime which: 'python3')
		arguments: {'/home/tom/Code/squeak/chi-2023-gpl-structured-editing/tasks/test-setup/key-count.py'}
		environment: nil
		descriptors: {nil. outputPipe writer. nil}
		workingDir: nil.
	outputPipe writer close
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> stopCollectKeys [

	| output data |
	Smalltalk platformName = 'Win32' ifTrue: [
		ExternalWindowsOSProcess command: ('taskkill /pid {1}' format: {keyListenerProcess pid}).
		[keyListenerProcess runState == #complete] whileFalse: [(Delay forMilliseconds: 50) wait].
		^ FileStream readOnlyFileNamed: 'out.txt' do: [:f | Json readFrom: f contents readStream]].
	
	keyListenerProcess sigint.
	[keyListenerProcess runState == #complete] whileFalse: [
		(Delay forMilliseconds: 50) wait.
		"have to sometimes hammer the process with signals for it to terminate, maybe the listener thread is eating the signal sometimes?"
		keyListenerProcess sigint].
	data := outputPipe upToEnd.
	keyListenerProcess := nil.
	
	output := Json readFrom: data readStream.
	^ output
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> times [

	^ times
]
