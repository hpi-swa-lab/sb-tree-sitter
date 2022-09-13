Class {
	#name : #SBTSLSPSemantics,
	#superclass : #SBTSLanguageSemantics,
	#instVars : [
		'client',
		'textDocumentVersions',
		'currentDiagnostics'
	],
	#category : #'Sandblocks-TreeSitter-Project'
}

{ #category : #helper }
SBTSLSPSemantics >> blockFor: aRange in: aRootBlock [

	| line character endCharacter endLine |
	line := aRange start line.
	character := aRange start character.
	endLine := aRange end line.
	endCharacter := aRange end character.
	
	aRootBlock allBlocksDo: [:block | (block range key line = line and: [block range key character = character and: [block range value line = endLine and: [block range value character = endCharacter]]]) ifTrue: [^ block]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSLSPSemantics >> choosingLabelFor: definition [

	^ 'some definition on line ', (definition at: 'range') start line
]

{ #category : #'as yet unclassified' }
SBTSLSPSemantics >> definitionsOf: aBlock choosing: aChoosingClosure do: aDefinitionClosure blocking: aBoolean [

	| textDocument |
	textDocument := self textDocumentFor: aBlock.
	client
		sendRequest: 'textDocument/typeDefinition'
		params: (Dictionary newFrom: {'textDocument' -> textDocument. 'position' -> aBlock range key forLSP})
		do: [:response |
			response ifNotNil: [:d | | definitions index |
				definitions := d isCollection ifTrue: [d] ifFalse: [{d}].
				index := aChoosingClosure value: (definitions collect: [:definition | self choosingLabelFor: definition]).
				definitions at: index ifPresent: [:definition | | root |
					root := definition uri = (textDocument at: 'uri')
						ifTrue: [aBlock root]
						ifFalse: [(aBlock sandblockEditor openFile: (self fileReferenceFrom: definition uri)) root].
					(self blockFor: (definition at: 'range') in: root) ifNotNil: aDefinitionClosure]]]
		blocking: aBoolean
]

{ #category : #notifications }
SBTSLSPSemantics >> didChange: aTSFile [

	| version |
	version := textDocumentVersions
		at: aTSFile
		put: (textDocumentVersions at: aTSFile) + 1.
	
	client sendNotification: 'textDocument/didChange' params: (Dictionary newFrom: {
		'textDocument' -> ((self textDocumentFor: aTSFile)
			addAll: {'version' -> version};
			yourself).
		'contentChanges' -> {Dictionary newFrom: {'text' -> aTSFile getSourceStringAndMark}}})
]

{ #category : #notifications }
SBTSLSPSemantics >> didClose: aTSFile [

	textDocumentVersions removeKey: aTSFile.
	
	client
		sendNotification: 'textDocument/didClose'
		params: (Dictionary newFrom: {'textDocument' -> (self textDocumentFor: aTSFile)})
]

{ #category : #notifications }
SBTSLSPSemantics >> didOpen: aTSFile [

	textDocumentVersions at: aTSFile put: 1.
	
	client sendNotification: 'textDocument/didOpen' params: (Dictionary newFrom: {
		'textDocument' -> ((self textDocumentFor: aTSFile)
			addAll: {'languageId' -> aTSFile root language language. 'version' -> 1. 'text' -> aTSFile getSourceStringAndMark};
			yourself)})
]

{ #category : #helper }
SBTSLSPSemantics >> fileReferenceFrom: aString [

	| uri |
	uri := URI fromString: aString unescapePercents.
	uri scheme = 'file' ifFalse: [self error: 'can only open file:// uris'].
	^ FileSystem disk referenceTo: uri absolutePath
]

{ #category : #helper }
SBTSLSPSemantics >> handleNotification: aJsonObject [

	aJsonObject method
		caseOf: {
			['textDocument/publishDiagnostics'] -> [ | file |
				file := textDocumentVersions keys detect: [:block | ((self textDocumentFor: block) at: 'uri') = aJsonObject params uri].
				currentDiagnostics at: file ifPresent: [:list | list do: #detach].
				currentDiagnostics at: file put: OrderedCollection new.
				aJsonObject params diagnostics do: [:diagnostic |
					(self blockFor: (diagnostic at: 'range') in: file) ifNotNil: [:block | | decorator |
						decorator := SBErrorDecorator new
							message: diagnostic message;
							subtle: true.
						(currentDiagnostics at: file) add: decorator.
						block attachDecorator: decorator]]]}
		otherwise: [Transcript showln: aJsonObject]
]

{ #category : #'initialize-release' }
SBTSLSPSemantics >> on: aDirectory [

	textDocumentVersions := Dictionary new.
	currentDiagnostics := Dictionary new.
	client := SBTSLanguageClient new
		initializeFor: aDirectory
		onNotificationDo: [:notification | self handleNotification: notification]
]

{ #category : #'initialize-release' }
SBTSLSPSemantics >> shutdown [

	client stop
]

{ #category : #helper }
SBTSLSPSemantics >> textDocumentFor: aBlock [

	^ Dictionary newFrom: {'uri' -> ('file://', aBlock containingArtefact filepath)}
]

{ #category : #requests }
SBTSLSPSemantics >> usagesOf: aBlock do: aClosure [

	client
		sendRequest: 'textDocument/documentHighlight'
		params: (Dictionary newFrom: {'textDocument' -> (self textDocumentFor: aBlock). 'position' -> aBlock range key forLSP})
		do: [:response | response ifNotNil: [:highlights | highlights do: [:highlight | (self blockFor: (highlight at: 'range') in: aBlock containingArtefact root) ifNotNil: [:b | aClosure value: b]]]]
		blocking: false
]
