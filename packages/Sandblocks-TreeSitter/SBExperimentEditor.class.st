Class {
	#name : #SBExperimentEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'server',
		'times'
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
SBExperimentEditor >> intoWorld: aWorld [

	| setHeaders |
	super intoWorld: aWorld.
	setHeaders := [:res |
		res headerAt: 'Content-Type' put: 'application/json'.
		res headerAt: 'Access-Control-Allow-Origin' put: '*'.
		res headerAt: 'Access-Control-Allow-Headers' put: '*'.
		res headerAt: 'Access-Control-Allow-Methods' put: '*'].
	Transcript showln: 'hello'.
	server := WebServer new listenOn: 8000.
	times := OrderedCollection new.
	server addService: '/report' action: [:req | | data raw |
		Transcript showln: req.
		req method = 'OPTIONS'
			ifTrue: [req send200Response: 'application/json' contentType: 'text/plain; charset=utf-8' do: setHeaders]
			ifFalse: [
				raw := req getContent.
				data := Json readFrom: raw readStream.
				times add: data.
				FileStream fileNamed: ('experiment-{1}.jsonl' format: {data at: 'runId'}) do: [:stream |
					stream
						setToEnd;
						nextPutAll: raw;
						cr;
						flush].
				req send200Response: 'application/json' contentType: 'text/plain; charset=utf-8' do: setHeaders]].
	server addService: '/code' action: [:req |
		Transcript showln: req.
		req method caseOf: {
			['OPTIONS'] -> [req send200Response: 'application/json' contentType: 'text/plain; charset=utf-8' do: setHeaders].
			['GET'] -> [
				Transcript showln: 'open code'.
				req
					send200Response: ({'code' -> self childSandblocks first sourceString withUnixLineEndings} as: Dictionary) asJsonString
					contentType: 'application/json'
					do: setHeaders].
			['POST'] -> [ | code |
				code := (Json readFrom: req getContent readStream) code.
				Project current addDeferredUIMessage: [
					code
						ifEmpty: [
							SBTutorialStep resetAllProgress.
							SBTSPyTutorial openIn: self]
						ifNotEmpty: [self openMorphInView: (SBPython parseToplevel: code)]].
				req send200Response: '{}' contentType: 'application/json' do: setHeaders]}]
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	server destroy
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> python [

	self openMorphInView: (SBPython parseToplevel: SBTSReconstructExperiment basicNew pythonFlaskBlueprints)
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> times [

	^ times
]
