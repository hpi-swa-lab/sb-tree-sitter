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

{ #category : #helper }
SBTSLSPSemantics >> choosingLabelFor: definition [

	| file start line |
	file := self fileReferenceFrom: definition uri.
	start := (definition at: 'range') start.
	"LSP indices are 0-based"
	line := file contents lineNumber: start line + 1.
	^ '{1} [{2} :{3}:{4}]' format: {line withBlanksTrimmed. file basename. start line + 1. start character + 1}
]

{ #category : #helper }
SBTSLSPSemantics >> completionItemKindToString: aNumber [

	^ (Dictionary newFrom: {
		1 -> 'text'.
		2 -> 'method'.
		3 -> 'function'.
		4 -> 'constructor'.
		5 -> 'field'.
		6 -> 'variable'.
		7 -> 'class'.
		8 -> 'interface'.
		9 -> 'module'.
		10 -> 'property'.
		11 -> 'unit'.
		12 -> 'value'.
		13 -> 'enum'.
		14 -> 'keyword'.
		15 -> 'snippet'.
		16 -> 'color'.
		17 -> 'file'.
		18 -> 'reference'.
		19 -> 'folder'.
		20 -> 'enumMember'.
		21 -> 'constant'.
		22 -> 'struct'.
		23 -> 'event'.
		24 -> 'operator'.
		25 -> 'typeParameter'}) at: aNumber
]

{ #category : #requests }
SBTSLSPSemantics >> definitionsOf: aBlock choosing: aChoosingClosure do: aDefinitionClosure blocking: aBoolean [

	client
		sendRequest: 'textDocument/typeDefinition'
		params: (self textDocumentPositionParamsFor: aBlock)
		do: [:response |
			response ifNotNil: [:d | | definitions index |
				definitions := d isCollection ifTrue: [d] ifFalse: [{d}].
				index := aChoosingClosure value: (definitions collect: [:definition | self choosingLabelFor: definition]).
				definitions at: index ifPresent: [:definition | | root |
					root := definition uri = ((self textDocumentFor: aBlock) at: 'uri')
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
SBTSLSPSemantics >> filterSuggestions: aCollection by: aBlock [

	^ aCollection select: [:suggestion | (suggestion at: 'filterText' ifAbsent: [suggestion label]) includesSubstring: aBlock contents]
]

{ #category : #helper }
SBTSLSPSemantics >> handleNotification: aJsonObject [

	aJsonObject method
		caseOf: {
			['textDocument/publishDiagnostics'] -> [ | file |
				file := textDocumentVersions keys
					detect: [:block | ((self textDocumentFor: block) at: 'uri') = aJsonObject params uri]
					ifNone: [^ self].
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

{ #category : #helper }
SBTSLSPSemantics >> offset: aPosition byCursor: aNumber in: aString [

	| typed lineOffset |
	typed := aString take: aNumber - 1.
	lineOffset := typed lineCount - 1.
	^ SBTSPosition
		line: aPosition line + lineOffset
		character: (lineOffset > 1 ifTrue: [typed lastLine] ifFalse: aPosition character + typed size)
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

{ #category : #requests }
SBTSLSPSemantics >> suggestionsFor: aBlock [

	^ OrderedCollection streamContents: [:stream | self suggestionsFor: aBlock do: [:suggestion | stream nextPut: suggestion] blocking: true]
]

{ #category : #requests }
SBTSLSPSemantics >> suggestionsFor: aBlock do: aClosure blocking: aBoolean [

	client
		sendRequest: 'textDocument/completion'
		params: (self textDocumentPositionParamsFor: aBlock)
		do: [:response |
			(self
				filterSuggestions: (response ifNotNil: [:object | object at: 'items' ifAbsent: [object]] ifNil: [{}])
				by: aBlock) do: [:item |
				aClosure value: (SBSuggestionItem selector: (item at: 'insertText' ifAbsent: item label) label: (item
					at: 'detail'
					ifAbsent: [item at: 'kind' ifPresent: [:kind | self completionItemKindToString: kind] ifAbsent: ['']]))]]
		blocking: aBoolean
]

{ #category : #helper }
SBTSLSPSemantics >> textDocumentFor: aBlock [

	^ Dictionary newFrom: {'uri' -> ('file://', aBlock containingArtefact filepath)}
]

{ #category : #requests }
SBTSLSPSemantics >> textDocumentPositionParamsFor: aBlock [

	| position |
	position := aBlock range key.
	aBlock currentTextMorph ifNotNil: [:text | text cursor > 0 ifTrue: [position := self offset: position byCursor: text cursor in: text contents]].
	^ Dictionary newFrom: {'textDocument' -> (self textDocumentFor: aBlock). 'position' -> position forLSP}
]

{ #category : #requests }
SBTSLSPSemantics >> usagesOf: aBlock do: aClosure [

	client
		sendRequest: 'textDocument/documentHighlight'
		params: (self textDocumentPositionParamsFor: aBlock)
		do: [:response | aBlock containingArtefact ifNotNil: [response ifNotNil: [:highlights | highlights do: [:highlight | (self blockFor: (highlight at: 'range') in: aBlock containingArtefact root) ifNotNil: [:b | aClosure value: b]]]]]
		blocking: false
]
