Class {
	#name : #SBWingRuntime,
	#superclass : #SBTSLanguageRuntime,
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingRuntime class >> activateFor: aFile do: aBlock [

	aFile children
		detect: [:file | file extension = 'w']
		ifFound: [:f | aBlock value: (self new root: aFile)]
]

{ #category : #'as yet unclassified' }
SBWingRuntime class >> language [

	^ SBWing
]

{ #category : #'as yet unclassified' }
SBWingRuntime >> startSemantics [

	^ SBTSLSPSemantics new
		on: self root
		transport: (SBLSPStdioTransport new
			command: (self class which: 'wing');
			arguments: {'lsp'};
			workingDirectory: self root asString)
		onReady: []
]
