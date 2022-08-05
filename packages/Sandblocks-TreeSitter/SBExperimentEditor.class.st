Class {
	#name : #SBExperimentEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'server'
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

	super intoWorld: aWorld.
	server := WebServer new listenOn: 9976.
	server
		addService: '/code'
		action: [:req | req send200Response: self childSandblocks first sourceString]
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	server destroy
]

{ #category : #'as yet unclassified' }
SBExperimentEditor >> python [

	self openMorphInView: (SBPython parseToplevel: SBTSReconstructTest basicNew pythonFlaskBlueprints)
]
