Class {
	#name : #SBTSFile,
	#superclass : #SBBlock,
	#instVars : [
		'filepath',
		'runButton',
		'runCancelBlock',
		'runtime',
		'root',
		'autoRestartButton',
		'autoRestart',
		'sematics'
	],
	#category : #'Sandblocks-TreeSitter-Files'
}

{ #category : #'as yet unclassified' }
SBTSFile class >> filepath: aString [

	^ self filepath: aString collapsed: false
]

{ #category : #'as yet unclassified' }
SBTSFile class >> filepath: aFilepathString collapsed: aBoolean [

	^ self new filepath: aFilepathString collapsed: aBoolean
]

{ #category : #'as yet unclassified' }
SBTSFile class >> for: aFilepathString [

	^ self filepath: aFilepathString collapsed: false
]

{ #category : #'as yet unclassified' }
SBTSFile class >> forNoReplace: aFilepathString [

	^ self new
		filepath: aFilepathString
		language: (self languageForPathAskInstall: aFilepathString)
		collapsed: false
		replace: false
]

{ #category : #'as yet unclassified' }
SBTSFile class >> languageForPath: aString [

	^ SBTSLanguage allSubclasses
		detect: [:lang | lang allFileSuffixes includes: (FileDirectory extensionFor: aString)]
		ifNone: [nil]
]

{ #category : #'as yet unclassified' }
SBTSFile class >> languageForPathAskInstall: aString [

	| ext |
	ext := FileDirectory extensionFor: aString.
	^ SBTSLanguage allSubclasses
		detect: [:lang | lang allFileSuffixes includes: ext]
		ifNone: [
			(UIManager default request: ('No languages installed for {1}. Install from Github?' format: {ext})) ifNotNil: [:url | | class |
				class := SBTSLanguage installFromGitHub: url.
				class class compile: ('allFileSuffixes ^ \{{1}}' format: {ext storeString}).
				class]]
]

{ #category : #'as yet unclassified' }
SBTSFile >> artefactChanged: aMethodBlock [

	aMethodBlock = self ifTrue: [ | changed |
		"FIXME: this heuristic will be wrong for changes that affect more than the selection.
		It also doesn't improve performance when changes happen on the toplevel"
		changed := (self sandblockEditor selection ifNotNil: [:selection | selection hasOwner: self] ifNil: [false]) ifTrue: [self sandblockEditor selection] ifFalse: [self root].
		changed isInlineBlock ifTrue: [changed updateAllHighlights]]
]

{ #category : #'as yet unclassified' }
SBTSFile >> artefactSaved: aMethodBlock [

	(aMethodBlock = self and: [autoRestart]) ifTrue: [self restart]
]

{ #category : #'as yet unclassified' }
SBTSFile >> deleteCommandFor: aBlock [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSFile >> evaluate: aBlock [

	^ runtime object ifNotNil: [:runtime |
		runtime new
			factory: aBlock language;
			evaluate: aBlock sourceString]
]

{ #category : #'as yet unclassified' }
SBTSFile >> evaluateString: aString [

	^ runtime object ifNotNil: [:runtime |
		runtime new
			factory: self root language;
			evaluate: aString]
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath [

	^ filepath
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath: aString collapsed: aBoolean [

	self filepath: aString language: (self class languageForPathAskInstall: aString) collapsed: aBoolean replace: true
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath: aString language: aLanguageClass collapsed: aCollapsedBoolean replace: aReplaceBoolean [

	self
		filepath: aString
		toplevel: (FileStream readOnlyFileNamed: aString do: [:stream | | toplevel |
			toplevel := SBTSFileParser new
				parse: stream contents
				language: aLanguageClass.
			aReplaceBoolean ifTrue: [toplevel applyReplacements] ifFalse: [toplevel]])
		language: aLanguageClass
		collapsed: aCollapsedBoolean
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath: aString toplevel: aBlock language: aLanguageClass collapsed: aBoolean [

	filepath := aString.
	autoRestart := false.
	self addMorphBack: (SBRow new
		cellGap: 4;
		cellPositioning: #center;
		addMorphBack: aLanguageClass iconMorph;
		addMorphBack: (SBStringMorph new
			contents: (FileDirectory localNameFor: aString);
			bold);
		addMorphBack: (Morph new
			extent: 8 @ 0;
			color: Color transparent)).
	root := aBlock
		hResizing: #spaceFill;
		minHeight: TextStyle defaultFont height.
	aBoolean ifFalse: [self addMorphBack: root].
	
	(self root language runtime notNil and: [aBoolean not]) ifTrue: [
		self firstSubmorph
			addMorphBack: (runtime := SBTSRuntimeChooser new language: aLanguageClass);
			addMorphBack: (runButton := SBIcon iconPlay
				balloonText: 'Run file';
				on: #click send: #toggleRun to: self);
			addMorphBack: (Morph new extent: 12 @ 0);
			addMorphBack: (autoRestartButton := SBButton new
				icon: SBIcon iconRefresh shortcut: nil do: [self toggleAutoRestart];
				balloonText: 'Toggle auto-restart on save')]
]

{ #category : #'as yet unclassified' }
SBTSFile >> getSourceStringAndMark [

	^ self root getSourceStringAndMark
]

{ #category : #'as yet unclassified' }
SBTSFile >> initialize [

	super initialize.
	
	self
		layoutInset: 4;
		useAlgebraLayout;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator new
]

{ #category : #'as yet unclassified' }
SBTSFile >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSFile >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs
			collect: [:s | s layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true])
]

{ #category : #'as yet unclassified' }
SBTSFile >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	self semantics didClose: self
]

{ #category : #'as yet unclassified' }
SBTSFile >> range [

	^ SBTSRange
		start: (SBTSPosition line: -1 character: -1)
		end: (SBTSPosition line: -1 character: -1)
]

{ #category : #'as yet unclassified' }
SBTSFile >> restart [

	runCancelBlock ifNotNil: [self toggleRun].
	self addAlarm: #toggleRun after: 500
]

{ #category : #'as yet unclassified' }
SBTSFile >> root [

	^ root
]

{ #category : #'as yet unclassified' }
SBTSFile >> runtime [

	^ runtime object new
]

{ #category : #'as yet unclassified' }
SBTSFile >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	| source |
	source := SBTSActiveRuntime
		value: (runtime ifNotNil: [:r | r object new factory: self root factory])
		during: [
			SBToggledCode comment: '' active: 1 do: {
				[self root getSourceStringAndMark].
				[
					aQuickBoolean
						ifTrue: [self root getSourceStringAndMark]
						ifFalse: [self root prettySourceString]]}].
	FileStream
		forceNewFileNamed: self filepath
		do: [:stream | stream nextPutAll: source withUnixLineEndings].
	^ true
]

{ #category : #accessing }
SBTSFile >> semantics [

	^ sematics ifNil: [SBTSLanguageSemantics new]
]

{ #category : #accessing }
SBTSFile >> semantics: aLanguageSemantics [

	sematics := aLanguageSemantics
]

{ #category : #'as yet unclassified' }
SBTSFile >> toggleAutoRestart [

	autoRestart := autoRestart not.
	autoRestartButton active: autoRestart
]

{ #category : #'as yet unclassified' }
SBTSFile >> toggleRun [

	runCancelBlock
		ifNotNil: [
			runCancelBlock value.
			runButton changeIconName: #iconPlay.
			runCancelBlock := nil]
		ifNil: [
			((runtime object new
				evaluateFileAsync: self filepath
				cancel: [:b | runCancelBlock := b]) then: [:b |
				b value: [:status :stdout :stderr |
					SBToggledCode comment: '' active: 1 do: {[Transcript showln: {status. stdout. stderr}]}.
					runButton changeIconName: #iconPlay.
					runCancelBlock := nil.
					(status ~= 0 and: [status ~= 15]) ifTrue: [self error: stderr]]]) ifRejected: [:err | err signal].
			runButton changeIconName: #iconStop]
]
