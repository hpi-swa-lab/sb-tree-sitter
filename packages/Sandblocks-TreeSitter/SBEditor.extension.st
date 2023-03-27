Extension { #name : #SBEditor }

{ #category : #'*Sandblocks-TreeSitter' }
SBEditor >> importTreeSitterLanguage [
	<globalAction>

	| url |
	url := (UIManager default request: 'Github URL?') ifNil: [^ self].
	self openMorphInView: (SBTSLanguage installFromGitHub: url) empty
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

	aLanguage runtime
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
