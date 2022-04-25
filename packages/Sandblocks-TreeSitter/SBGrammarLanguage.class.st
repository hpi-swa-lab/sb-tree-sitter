Class {
	#name : #SBGrammarLanguage,
	#superclass : #SBMetaBlockFactory,
	#classInstVars : [
		'instance'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> allRuntimes [

	^ Array streamContents: [:stream | SBTSLanguageRuntime allSubclassesDo: [:cl | cl language = self ifTrue: [stream nextPut: cl]]]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> build: aRuleName [

	^ self instance instantiateTemplate: aRuleName
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> canParse: aString [

	^ [
		self parse: aString.
		true]
		on: SBTSSyntaxError
		do: [false]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> defaultRuntimeClass [

	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> expressionTypes [

	^ #()
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> file: aFilenameString [

	^ SBTSFile new filepath: aFilenameString language: self
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> fileSuffix [

	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> grammarJson [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> grammarJsonObject [

	^ Json readFrom: self grammarJson readStream
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> highlightQuery [

	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> icon [

	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> iconMorph [

	^ self icon ifNotNil: #asMorph ifNil: [SBIcon iconFile]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> initialize [

	self allSubclassesDo: #invalidate
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> instance [

	^ instance ifNil: [instance := self new]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> invalidate [

	instance := nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> language [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parse: aString [

	^ self instance parse: aString
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parseAndReplace: aString [

	^ (self instance parse: aString) applyReplacements
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parseElement: aString [

	| program |
	program := self instance parse: aString.
	^ self instance rootRuleName = program type
		ifTrue: [
			self
				assert: program childSandblocks size = 1
				description: 'More than one child was returned from the parsed expression. Consider using parse: instead.'.
			program childSandblocks first]
		ifFalse: [program]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parseExpression: aString [

	| toplevel |
	toplevel := SBTSFileParser new parse: aString language: self.
	self
		assert: toplevel childSandblocks size = 1
		description: 'More than one child was returned from the parsed expression. Consider using parse: instead.'.
	^ toplevel childSandblocks first
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parseToplevel: aString [

	| toplevel |
	toplevel := SBTSFileParser new parseTopLevel: aString language: self.
	^ toplevel
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> rebuild [

	self invalidate.
	^ self instance
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> rootRuleName [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> statementContainerTypes [

	^ #()
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> toplevel [

	^ self instance toplevel
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> unknownFor: aSymbol [

	| morphs |
	morphs := (self instance bodyNodeForRule: aSymbol) buildEmpty.
	(morphs size = 1 and: [morphs first isUnknown]) ifTrue: [^ morphs anyOne].
	^ SBTSBlock new
		slot: (SBTSSlot new addNode: (SBTSNodeSymbol new type: aSymbol factory: self instance));
		addAllMorphs: morphs;
		yourself
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> updateFrom: aGithubString branch: aString [

	| path grammarFile highlightsFile |
	path := self fetchLibrary: aGithubString branch: aString.
	self compileParserIn: path name: self language.
	
	[
		grammarFile := path / 'src' / 'grammar.json' in: [:file | file exists ifTrue: [FileStream readOnlyFileNamed: file fullName] ifFalse: [nil]].
		highlightsFile := path / 'queries' / 'highlights.scm' in: [:file | file exists ifTrue: [FileStream readOnlyFileNamed: file fullName] ifFalse: [nil]].
		
		self class
			compile: ('grammarJson

    " https://github.com/{1}/blob/master/src/grammar.json "
    ^ {2}' format: {self language. grammarFile contents storeString})
			classified: 'properties'.
		highlightsFile ifNotNil: [:f |
			self class
				compile: ('highlightQuery

    " https://github.com/{1}/blob/master/src/queries/highlights.scm "
    ^ {2}' format: {self language. f contents storeString})
				classified: 'properties']] ensure: [
		grammarFile ifNotNil: #close.
		highlightsFile ifNotNil: #close].
	
	self rebuild
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> configure [
	" entry point for calling configuration methods on the processed grammar, e.g. blockInline:, or delimitedRules: "

	
]

{ #category : #semantics }
SBGrammarLanguage >> declarationsInScope: aScopeBlock do: aClosure [

	
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> initialize [

	super initialize.
	
	grammar := Json readFrom: self class grammarJson readStream.
	self supertypes: grammar supertypes.
	name := self class language.
	highlightQuery := self class highlightQuery ifNotNil: [:query | SBTSQuery new prepare: query].
	extras := grammar extras
		select: [:rule | rule type = 'SYMBOL']
		thenCollect: [:rule | rule name].
	
	self wordRule: grammar word.
	self rootRuleName: self class rootRuleName.
	self statementContainerTypes: self class statementContainerTypes.
	self expressionTypes: self class expressionTypes.
	
	self preprocessGrammar.
	self cleanGrammar.
	self configure.
	self prepareBlocks.
	self findBlockInlineCandidates.
	self postConfigure
]

{ #category : #semantics }
SBGrammarLanguage >> isIdentifier: aBlock [

	^ aBlock type = 'identifier'
]

{ #category : #semantics }
SBGrammarLanguage >> isScope: aBlock [

	^ aBlock isBlockBody
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> postConfigure [

	
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> prepareBlocks [

	grammar rules keysAndValuesDo: [:name :r |
		self getTemplate: name.
		self bodyNodeForRule: name ifAbsent: []]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> preprocessGrammar [
	" entrypoint to clean the grammar before the automated steps happen, e.g. replacing or removing external rules "

	
]

{ #category : #semantics }
SBGrammarLanguage >> resolveDeclaration: aBlock [

	self scopesAround: aBlock do: [:scope :declarations |
		declarations
			detect: [:decl | decl contents = aBlock contents]
			ifFound: [:decl | ^ decl block]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> runtime [

	SBTSActiveRuntime value ifNotNil: [:runtime | runtime class language = self class ifTrue: [^ runtime]].
	
	^ self class defaultRuntimeClass ifNotNil: [:cl | cl new factory: self]
]

{ #category : #semantics }
SBGrammarLanguage >> scopesAround: aBlock do: aClosure [

	| current |
	current := aBlock.
	[current notNil and: [current isTSBlock]] whileTrue: [
		(self isScope: current) ifTrue: [
			aClosure
				value: current
				value: (Array streamContents: [:stream | self declarationsInScope: current do: [:decl | stream nextPut: decl]])].
		current := current parentSandblock]
]

{ #category : #semantics }
SBGrammarLanguage >> usagesOf: aBlock do: aClosure [

	(self resolveDeclaration: aBlock) ifNotNil: [:declaration | (self usagesOfDeclaration: declaration) do: [:usage | aClosure value: usage]]
]

{ #category : #semantics }
SBGrammarLanguage >> usagesOfDeclaration: aDeclaration [

	self
		scopesAround: aDeclaration
		do: [:scope :declarations | ^ Array streamContents: [:stream | scope allBlocksDo: [:block | (block isTSBlock and: [(self isIdentifier: block) and: [block contents = aDeclaration contents]]) ifTrue: [stream nextPut: block]]]].
	^ #()
]
