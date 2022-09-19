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
SBTSLSPSemantics >> applyChange: change toFile: aTSFile [

	| range block |
	range := change at: 'range'.
	block := aTSFile root smallestBlockEncompassig: range.
	block range = range ifTrue: [block changeToUnknown] ifFalse: [
		range isEmpty ifFalse: [self error: 'unsupported change'].
		block sandblockEditor cursorPosition: (self insertPositionIn: block at: range start for: change newText withBlanksCondensed)].
	self type: change newText in: aTSFile sandblockEditor
]

{ #category : #helper }
SBTSLSPSemantics >> applyChanges: aCollection toFile: aTSFile [

	aCollection do: [:change | change at: 'range' put: (SBTSRange fromLSPWithRange: change)].
	(aCollection sorted: [:a :b | (a at: 'range') start >= (b at: 'range') start]) do: [:change | self applyChange: change toFile: aTSFile]
]

{ #category : #helper }
SBTSLSPSemantics >> applyChanges: aCollection toSource: aString [

	| source changes newSource lineIndex multilineChange line |
	source := ReadStream on: aString.
	changes := Dictionary new.
	aCollection do: [:change | (changes at: (change at: 'range') start line ifAbsentPut: [OrderedCollection new]) add: change].
	newSource := WriteStream on: ''.
	lineIndex := 0.
	multilineChange := nil.
	line := nil.
	[line := source nextLine] whileNotNil: [ | restLine character |
		restLine := line.
		character := 0.
		multilineChange ifNotNil: [
			(multilineChange at: 'range') end line = lineIndex ifTrue: [
				character := (multilineChange at: 'range') end character.
				restLine := line copyFrom: character + 1.
				multilineChange := nil]].
		multilineChange ifNil: [
			((changes at: lineIndex ifAbsent: [{}]) sorted: [:a :b | (a at: 'range') start character < (b at: 'range') start character]) do: [:change |
				newSource
					nextPutAll: (restLine take: (change at: 'range') start character - character);
					nextPutAll: change newText.
				(change at: 'range') end line = lineIndex
					ifTrue: [
						restLine := restLine allButFirst: (change at: 'range') end character - character.
						character := (change at: 'range') end character]
					ifFalse: [multilineChange := change]]].
		multilineChange ifNil: [
			newSource
				nextPutAll: restLine;
				crlf].
		lineIndex := lineIndex + 1].
	^ newSource contents
]

{ #category : #'as yet unclassified' }
SBTSLSPSemantics >> applyEdit: anEdit [

	anEdit changes keysAndValuesDo: [:uri :changes | (self findFileByUri: uri) ifNotNil: [:file | self applyChanges: changes toFile: file]]
]

{ #category : #helper }
SBTSLSPSemantics >> blockFor: aRange in: aRootBlock [

	aRootBlock allBlocksDo: [:block | block range = aRange ifTrue: [^ block]].
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

{ #category : #requests }
SBTSLSPSemantics >> codeActionsFor: aBlock choosing: aClosure blocking: aBoolean [

	client
		sendRequest: 'textDocument/codeAction'
		params: (Dictionary newFrom: {
			'textDocument' -> (self textDocumentFor: aBlock).
			'range' -> aBlock range forLSP.
			'context' -> (Dictionary newFrom: {
				'diagnostics' -> ((currentDiagnostics at: aBlock containingArtefact ifAbsent: [{}]) collect: [:decorator | decorator diagnostic])})})
		do: [:response | | actions chosenIndex |
			actions := response ifNil: [{}].
			chosenIndex := aClosure value: (actions collect: [:action | action title]).
			actions at: chosenIndex ifPresent: [:action | self runAction: action]]
		blocking: aBoolean
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
					(self blockFor: (SBTSRange fromLSPWithRange: definition) in: root) ifNotNil: aDefinitionClosure]]]
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

	^ aCollection select: [:suggestion | (suggestion at: 'filterText' ifAbsent: [suggestion label]) sandblockMatch: aBlock contents]
]

{ #category : #helper }
SBTSLSPSemantics >> findFileByUri: aUri [

	^ textDocumentVersions keys
		detect: [:block | ((self textDocumentFor: block) at: 'uri') = aUri]
		ifNone: [nil]
]

{ #category : #helper }
SBTSLSPSemantics >> handleServerMessage: aJsonObject [

	aJsonObject method
		caseOf: {
			['textDocument/publishDiagnostics'] -> [ | file |
				file := (self findFileByUri: aJsonObject params uri) ifNil: [^ self].
				currentDiagnostics at: file ifPresent: [:list | list do: #detach].
				currentDiagnostics at: file put: OrderedCollection new.
				aJsonObject params diagnostics do: [:diagnostic |
					(self blockFor: (SBTSRange fromLSPWithRange: diagnostic) in: file) ifNotNil: [:block | | decorator |
						decorator := SBTSDiagnosticDecorator new
							diagnostic: diagnostic;
							yourself.
						(currentDiagnostics at: file) add: decorator.
						block attachDecorator: decorator]]].
			['workspace/applyEdit'] -> [
				self applyEdit: aJsonObject params edit.
				client respondToRequest: aJsonObject id result: (Dictionary newFrom: {'applied' -> false})]}
		otherwise: [Transcript showln: aJsonObject]
]

{ #category : #helper }
SBTSLSPSemantics >> insertPositionIn: aBlock at: aTSPosition for: aString [

	| block root |
	block := aBlock.
	root := aBlock sandblockEditor root.
	[block ~~ root and: [block range start = aTSPosition or: [block range end = aTSPosition]]] whileTrue: [block := block parentSandblock].
	block cursorPositionsDo: [:pos |
		(pos isInsert
			and: [pos command insertRange contains: aTSPosition]
			and: [(SBTSInputParser new optionsForTemplate: pos command element given: aString) notEmpty]) ifTrue: [^ pos]].
	self error: 'weird change'
]

{ #category : #'initialize-release' }
SBTSLSPSemantics >> on: aDirectory [

	textDocumentVersions := Dictionary new.
	currentDiagnostics := Dictionary new.
	client := SBTSLanguageClient new
		initializeFor: aDirectory
		onServerMessageDo: [:message | self handleServerMessage: message]
]

{ #category : #'as yet unclassified' }
SBTSLSPSemantics >> runAction: anAction [

	anAction at: 'edit' ifPresent: [:edit | self applyEdit: edit].
	anAction
		at: 'command'
		ifPresent: [:command | self runCommand: (command isString ifTrue: [anAction] ifFalse: [command])]
]

{ #category : #'as yet unclassified' }
SBTSLSPSemantics >> runCommand: aCommand [
	"the response is irrelevant"

	client sendRequest: 'workspace/executeCommand' params: aCommand do: [:response | ] blocking: false
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
	position := aBlock range start.
	aBlock currentTextMorph ifNotNil: [:text | text cursor > 0 ifTrue: [position := position offsetBy: (SBTSPosition fromIndex: text cursor in: text contents)]].
	^ Dictionary newFrom: {'textDocument' -> (self textDocumentFor: aBlock). 'position' -> position forLSP}
]

{ #category : #helper }
SBTSLSPSemantics >> type: aString in: anEditor [

	aString withBlanksCondensed do: [:char | | event |
		event := SBTest keyboardEvent: char.
		event becomeActiveDuring: [anEditor handle: event]]
]

{ #category : #requests }
SBTSLSPSemantics >> usagesOf: aBlock do: aClosure [

	client
		sendRequest: 'textDocument/documentHighlight'
		params: (self textDocumentPositionParamsFor: aBlock)
		do: [:response | aBlock containingArtefact ifNotNil: [response ifNotNil: [:highlights | highlights do: [:highlight | (self blockFor: (SBTSRange fromLSPWithRange: highlight) in: aBlock containingArtefact root) ifNotNil: [:b | aClosure value: b]]]]]
		blocking: false
]
