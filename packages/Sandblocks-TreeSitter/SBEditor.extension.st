Extension { #name : #SBEditor }

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> importTreeSitterLanguage [
	<globalAction>

	| url name |
	url := (UIManager default request: 'Github URL?') ifNil: [^ self].
	(url beginsWith: 'https://github.com/') ifTrue: [url := url allButFirst: 'https://github.com/' size].
	name := (url regex: 'tree-sitter-(.+)' matchesCollect: [:m | m allButFirst: 'tree-sitter-' size]) first.
	'Importing ', name displayProgressFrom: 1 to: 2 during: [:bar |
		bar value: 1.
		SBTSLanguage loadLanguage: url name: name branch: 'master'.
		bar value: 2].
	
	self openMorphInView: (Smalltalk at: ('SB', name capitalized) asSymbol) empty
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newCFile [
	<addAction>

	self newFileFor: SBC
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newClojureFile [
	<addAction>

	self newFileFor: SBClojure
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newCppFile [
	<addAction>

	self newFileFor: SBCpp
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newFileFor: aLanguage [

	SBTSLanguageRuntime new
		factory: aLanguage;
		tmpFile: '' do: [:path | | file |
			file := SBTSFile for: path.
			self createArtefactInView: file.
			file lastDeepChild startInsertAtEnd]
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newJavascriptFile [
	<addAction>

	self newFileFor: SBJavascript
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newKotlinFile [
	<addAction>

	self newFileFor: SBKotlin
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newPythonFile [
	<addAction>

	self newFileFor: SBPython
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newRegexFile [
	<addAction>

	self newFileFor: SBRegex
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newSmalltalkFile [
	<addAction>

	SBTSLanguageRuntime new
		factory: SBTSSmalltalk;
		tmpFile: 'method' do: [:path | | file |
			file := SBTSFile for: path.
			self createArtefactInView: file.
			file lastDeepChild startInsertAtEnd]
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> newTypescriptFile [
	<addAction>

	self newFileFor: SBTypescript
]

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> openTreeSitterQueryDebugger [
	<addAction>
	<label: 'Tree Sitter Query Debugger'>

	self createArtefactInView: SBTSQueryDebugger new
]
