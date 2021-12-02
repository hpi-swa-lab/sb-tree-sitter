Class {
	#name : #SBTreeSitter,
	#superclass : #ExternalLibrary,
	#instVars : [
		'currentString',
		'language'
	],
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTreeSitter class >> moduleName [

	^ 'tree-sitter'
]

{ #category : #'as yet unclassified' }
SBTreeSitter >> buildTreeFrom: aCursor do: aBlock [

	| field fallback type fieldStream block template root |
	type := aCursor type.
	field := aCursor currentFieldName.
	fallback := {field. aCursor text}.
	
	template := aCursor isNamed
		ifTrue: [aCursor factory getTemplate: type ifAbsent: [^ aBlock value: aCursor text]]
		ifFalse: [^ aBlock value: aCursor text].
	
	template = 'ALIAS'
		ifTrue: [
			root := aCursor resolveAlias: type in: aCursor parentType.
			(root isKindOf: SBInlineBlockSymbol) ifTrue: [type := root type]]
		ifFalse: [root := SBInlineBlockSymbol new type: type factory: aCursor factory].
	
	fieldStream := ((Array streamContents: [:stream |
		aCursor gotoFirstChild ifTrue: [ | first |
			first := aCursor node.
			[self buildTreeFrom: aCursor do: [:b | stream nextPut: {aCursor currentFieldName. b}]] doWhileFalse: [ | gap atEnd |
				atEnd := aCursor gotoNextSibling.
				(atEnd not and: [aCursor factory noteUncapturedText includes: type]) ifTrue: [
					gap := aCursor textBetween: first and: aCursor node.
					gap size > 0 ifTrue: [stream nextPut: {#sp. gap}].
					first := aCursor node].
				atEnd].
			aCursor gotoParent]]) ifEmpty: [{fallback}]) readStream.
	
	block := SBTSParseExplore new
		explore: fieldStream
		root: root
		factory: aCursor factory.
	template = 'ALIAS' ifTrue: [block alias: type].
	self assert: block notNil description: 'failed to build ', type.
	^ aBlock value: block
]

{ #category : #ffi }
SBTreeSitter >> cursor: aCursor reset: aNode [

	<apicall: void ts_tree_cursor_reset (SBTSTreeCursor* SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorCopy: aCursor [

	<apicall: SBTSTreeCursor ts_tree_cursor_copy (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorCurrentFieldName: aCursor [

	<apicall: char* ts_tree_cursor_current_field_name (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorCurrentNode: aCursor [

	<apicall: SBTSNode ts_tree_cursor_current_node (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorDelete: aCursor [

	<apicall: void ts_tree_cursor_delete (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorGotoFirstChild: aCursor [

	<apicall: bool ts_tree_cursor_goto_first_child (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorGotoNextSibling: aCursor [

	<apicall: bool ts_tree_cursor_goto_next_sibling (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorGotoParent: aCursor [

	<apicall: bool ts_tree_cursor_goto_parent (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorNew: root [

	<apicall: SBTSTreeCursor ts_tree_cursor_new (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #helper }
SBTreeSitter >> externalCallFailed [

	^ ExternalFunction getLastError = 15
		ifTrue: [ | path |
			Smalltalk platformName = 'Mac OS' ifTrue: [
				thisContext sender method externalLibraryName: 'libtree-sitter.dylib'.
				^ thisContext sender method externalLibraryFunction invokeWithArguments: thisContext sender arguments].
			
			path := SBMetaBlockFactory fetchTreeSitter fullName.
			self class methodDict valuesDo: [:method | " only change for those that don't have an explicit module (lang-specific) "
			method methodReference category ~= 'ffi languages' ifTrue: [method externalLibraryName: path]].
			thisContext sender method externalLibraryFunction invokeWithArguments: thisContext sender arguments]
		ifFalse: [self externalCallFailed]
]

{ #category : #helper }
SBTreeSitter >> fetchLibrary: aGithubString language: language andRetry: aBlock [

	SBToggledCode comment: '' active: 1 do: {
		[ | path filename |
			filename := 'tree-sitter-{1}.so' format: {language}.
			path := (MCFetchGithubRepository new
				projectPath: aGithubString
				projectVersion: 'master'
				repoPath: nil) directory.
			OSProcess waitForCommand: ('cd {1}; npx -p tree-sitter-cli tree-sitter generate' format: {path fullName}).
			OSProcess waitForCommand: ('cd {1}; gcc -shared -fPIC -o {2} src/parser.c -I./src/' format: {path fullName. filename}).
			path / filename copyHere: FileDirectory default / filename.
			aBlock value].
		[ | zip |
			zip := WebClient httpGet: 'https://api.github.com/repos/', aGithubString, '/zipball/master'.
			ZipArchive new
				readFrom: zip getContent readStream binary;
				extractAllTo: (FileDirectory default / 'tree-sitter-languages') assureExistence
					informing: nil
					overwrite: false]}
]

{ #category : #'ffi languages' }
SBTreeSitter >> gdscript [

	<apicall: SBTSLanguage* tree_sitter_gdscript () module: 'tree-sitter-gdscript'>
	^ SBMetaBlockFactory tryPatchLibrary: 'PrestonKnopp/tree-sitter-gdscript' name: 'gdscript' context: thisContext
]

{ #category : #'ffi languages' }
SBTreeSitter >> java [

	<apicall: SBTSLanguage* tree_sitter_java () module: 'tree-sitter-java'>
	^ SBMetaBlockFactory tryPatchLibrary: 'tree-sitter/tree-sitter-java' name: 'java' context: thisContext
]

{ #category : #'ffi languages' }
SBTreeSitter >> javascript [

	<apicall: SBTSLanguage* tree_sitter_javascript () module: 'tree-sitter-javascript'>
	^ SBMetaBlockFactory tryPatchLibrary: 'tree-sitter/tree-sitter-javascript' name: 'javascript' context: thisContext
]

{ #category : #'ffi languages' }
SBTreeSitter >> json [

	<apicall: SBTSLanguage* tree_sitter_json () module: 'tree-sitter-json'>
	^ SBMetaBlockFactory tryPatchLibrary: 'tree-sitter/tree-sitter-json' name: 'json' context: thisContext
]

{ #category : #accessing }
SBTreeSitter >> language [

	^ language
]

{ #category : #ffi }
SBTreeSitter >> language: language symbolForName: aString length: aNumber isNamed: aBoolean [

	<apicall: uint16_t ts_language_symbol_for_name (void* char* uint32_t bool)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> node: aNode childByFieldName: aString length: aNumber [

	<apicall: SBTSNode ts_node_child_by_field_name (SBTSNode char* uint32_t)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeEndByte: aNode [

	<apicall: uint32_t ts_node_end_byte (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeHasError: aNode [

	<apicall: bool ts_node_has_error (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeIsNamed: aNode [

	<apicall: bool ts_node_is_named (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeParent: aNode [

	<apicall: SBTSNode ts_node_parent (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodePrivAlias: aNode [

	<apicall: uint16_t ts_node__alias (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeStartByte: aNode [

	<apicall: uint32_t ts_node_start_byte (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeString: aNode [

	<apicall: char* ts_node_string (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeSymbol: aNode [

	<apicall: uint16_t ts_node_symbol (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeType: aNode [

	<apicall: char* ts_node_type (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #'as yet unclassified' }
SBTreeSitter >> parse: aString language: aSymbol factory: aFactory [

	^ self parseAsCursor: aString language: aSymbol do: [:cursor |
		(self buildTreeFrom: (SBTSCursor new library: self cursor: cursor factory: aFactory) do: [:b | b])
			hResizing: #rigid;
			attachDecorator: SBResizableDecorator new;
			updateAllHighlights]
]

{ #category : #'as yet unclassified' }
SBTreeSitter >> parseAsCursor: aString language: aSymbol do: aBlock [

	| parser root tree cursor wasFreed |
	currentString := aString withUnixLineEndings.
	parser := self parserNew.
	language := self perform: aSymbol asSymbol.
	
	self parser: parser setLanguage: language.
	
	tree := self parser: parser old: nil parseString: currentString length: currentString size.
	
	root := self treeRootNode: tree.
	cursor := self cursorNew: root.
	wasFreed := false.
	
	^ [aBlock value: cursor] ensure: [
		" there were problems with double-free when debugging "
		wasFreed ifFalse: [
			wasFreed := true.
			self cursorDelete: cursor.
			self parserDelete: parser]]
]

{ #category : #ffi }
SBTreeSitter >> parser: aParserPointer old: aTreePointer parseString: aString length: aNumber [

	<apicall: void* ts_parser_parse_string (void* void* char* uint32_t)> 
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> parser: aParserPointer setLanguage: aLanguagePointer [

	<apicall: void ts_parser_set_language (void* SBTSLanguage*)> 
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> parserDelete: aCursor [

	<apicall: void ts_parser_delete (void*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> parserNew [

	<apicall: void* ts_parser_new ()> 
	^ self externalCallFailed
]

{ #category : #helper }
SBTreeSitter >> printTree: aCursor factory: aFactory [

	| node type |
	node := self cursorCurrentNode: aCursor.
	type := self nodeType: node.
	
	Transcript showln: type.
	
	(self cursorGotoFirstChild: aCursor) ifTrue: [
		self printTree: aCursor factory: aFactory.
		[self cursorGotoNextSibling: aCursor] whileTrue: [self printTree: aCursor factory: aFactory].
		self cursorGotoParent: aCursor]
]

{ #category : #'as yet unclassified' }
SBTreeSitter >> printTreeFrom: aCursor depth: aNumber [

	Transcript showln: {
		String streamContents: [:s | aNumber timesRepeat: [s nextPut: Character tab]].
		aCursor currentFieldName.
		aCursor type.
		aCursor text}.
	aCursor gotoFirstChild ifTrue: [
		[self printTreeFrom: aCursor depth: aNumber + 1] doWhileFalse: [aCursor gotoNextSibling].
		aCursor gotoParent]
]

{ #category : #'ffi languages' }
SBTreeSitter >> python [

	<apicall: SBTSLanguage* tree_sitter_python () module: 'tree-sitter-python'>
	^ SBMetaBlockFactory tryPatchLibrary: 'tree-sitter/tree-sitter-python' name: 'python' context: thisContext
]

{ #category : #'ffi languages' }
SBTreeSitter >> regex [

	<apicall: SBTSLanguage* tree_sitter_regex () module: 'tree-sitter-regex'>
	^ SBMetaBlockFactory tryPatchLibrary: 'tree-sitter/tree-sitter-regex' name: 'regex' context: thisContext
]

{ #category : #'ffi languages' }
SBTreeSitter >> ruby [

	<apicall: SBTSLanguage* tree_sitter_ruby () module: 'tree-sitter-ruby'>
	^ SBMetaBlockFactory tryPatchLibrary: 'tree-sitter/tree-sitter-ruby' name: 'ruby' context: thisContext
]

{ #category : #'ffi languages' }
SBTreeSitter >> sexp [

	<apicall: SBTSLanguage* tree_sitter_sexp () module: 'tree-sitter-sexp'>
	^ SBMetaBlockFactory tryPatchLibrary: 'AbstractMachinesLab/tree-sitter-sexp' name: 'sexp' context: thisContext
]

{ #category : #helper }
SBTreeSitter >> textBetween: aNode and: anEndNode [
	" TODO: will break with UTF-8 "

	^ currentString copyFrom: (self nodeEndByte: aNode) + 1 to: (self nodeStartByte: anEndNode)
]

{ #category : #helper }
SBTreeSitter >> textForNode: aNode [
	" TODO: will break with UTF-8 "

	^ currentString copyFrom: (self nodeStartByte: aNode) + 1 to: (self nodeEndByte: aNode)
]

{ #category : #ffi }
SBTreeSitter >> treeRootNode: aTree [

	<apicall: SBTSNode ts_tree_root_node (void*)>
	^ self externalCallFailed
]

{ #category : #'ffi languages' }
SBTreeSitter >> tsq [

	<apicall: SBTSLanguage* tree_sitter_tsq () module: 'tree-sitter-tsq'>
	^ SBMetaBlockFactory tryPatchLibrary: 'tree-sitter/tree-sitter-tsq' name: 'tsq' context: thisContext
]
