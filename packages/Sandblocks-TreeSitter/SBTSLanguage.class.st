Class {
	#name : #SBTSLanguage,
	#superclass : #Object,
	#instVars : [
		'grammar'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'Sandblocks-TreeSitter-Grammar'
}

{ #category : #'configuration - layout' }
SBTSLanguage class >> addIndent: aBlock [

	((aBlock isTextMorph or: [aBlock isStringMorph]) and: [{'{'. '('. '['. '<'} includes: aBlock effectiveContents]) ifTrue: [^ true].
	^ false
]

{ #category : #accessing }
SBTSLanguage class >> allFileSuffixes [

	^ {self fileSuffix}
]

{ #category : #accessing }
SBTSLanguage class >> allRuntimes [

	^ Array streamContents: [:stream | SBTSLanguageRuntime allSubclassesDo: [:cl | (cl languages includes: self) ifTrue: [stream nextPut: cl]]]
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> alwaysEnlargeInsets [

	^ false
]

{ #category : #'instantiate blocks' }
SBTSLanguage class >> blockFor: aSymbol [

	^ (SBTSNodeSymbol new type: aSymbol factory: self instance grammar) buildEmpty first
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> canInline: aSymbol [

	^ (#(#'_type_query_member_expression' #'_type_query_subscript_expression' #'_type_query_call_expression') includes: aSymbol) not
]

{ #category : #'instantiate blocks' }
SBTSLanguage class >> canParse: aString [

	^ [
		self parse: aString.
		true]
		on: SBTSSyntaxError
		do: [false]
]

{ #category : #configuration }
SBTSLanguage class >> commentSymbols [

	^ {#comment}
]

{ #category : #'loading - helper' }
SBTSLanguage class >> compileParserIn: path name: aString root: aRootPath [

	| filename hasScanner |
	filename := 'tree-sitter-', aString, '.so'.
	hasScanner := false.
	SBToggledCode comment: '' active: 0 do: {
		[
			self assert: (OSProcess waitForCommand: ('cd {1}; npm i' format: {aRootPath fullName})) exitStatus = 0.
			self assert: (OSProcess waitForCommand: ('cd {1}; npx -p tree-sitter-cli tree-sitter generate' format: {path fullName})) exitStatus = 0]}.
	((path / 'src' / 'scanner.c') exists or: [(path / 'src' / 'scanner.cc') exists]) ifTrue: [
		self assert: (OSProcess waitForCommand: ('cd {1}; CXXFLAGS="-I./src -fPIC" CFLAGS="-I./src -fPIC" make src/scanner.o' format: {path fullName})) exitStatus = 0.
		hasScanner := true].
	self assert: (OSProcess waitForCommand: ('cd {1}; CXXFLAGS="-I./src -fPIC" CFLAGS="-I./src  -fPIC" make src/parser.o' format: {path fullName})) exitStatus = 0.
	self assert: (OSProcess waitForCommand: ('cd {1}; g++ -shared -fPIC -o tree-sitter-{2}.so src/parser.o {3} -fPIC' format: {path fullName. aString. hasScanner ifTrue: [' src/scanner.o'] ifFalse: ['']})) exitStatus = 0.
	(FileDirectory default / filename) exists ifTrue: [(FileDirectory default / filename) delete].
	path / filename copyTo: FileDirectory default.
	^ FileDirectory default / ('tree-sitter-{1}.so' format: {aString})
]

{ #category : #'configuration - declarations' }
SBTSLanguage class >> declarationsInScope: aScopeBlock do: aClosure [

	
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> defaultChoiceDuringInputFor: aChoiceNode [

	^ nil
]

{ #category : #configuration }
SBTSLanguage class >> defaultRuntimeClass [

	^ nil
]

{ #category : #'instantiate blocks' }
SBTSLanguage class >> empty [

	^ (self blockFor: self rootRuleName)
		hResizing: #rigid;
		layoutInset: 12;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		extent: 100 @ (TextStyle defaultFont height + (12 * 2))
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> emptyLineSymbol [

	^ #empty
]

{ #category : #'loading - helper' }
SBTSLanguage class >> fetchLibrary: aGithubString branch: aString [

	^ (MCFetchGithubRepository new
		projectPath: aGithubString
		projectVersion: aString
		repoPath: nil)
		flushForScriptGet;
		directory
]

{ #category : #'loading - helper' }
SBTSLanguage class >> fetchTreeSitter [

	| path |
	path := self fetchLibrary: 'tree-sitter/tree-sitter' branch: 'master'.
	self assert: (OSProcess waitForCommand: ('cd {1}; make' format: {path fullName})) exitStatus = 0.
	path / 'libtree-sitter.so' copyTo: FileDirectory default.
	^ FileDirectory default / 'libtree-sitter.so'
]

{ #category : #configuration }
SBTSLanguage class >> fileSuffix [

	^ nil
]

{ #category : #'loading - helper' }
SBTSLanguage class >> firstRuleName [

	| r |
	r := '"rules"\:[\s\r\n]*\{[\s\r\n]*"([A-Za-z_]+)"' asRegex.
	r matchesIn: self grammarJson do: [:m | ^ r subexpression: 2].
	self error: 'first rule could not be detected'
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> gapBetween: aBlock and: anotherBlock [

	^ true
]

{ #category : #'loading - helper' }
SBTSLanguage class >> generateFFIMethodFor: aName github: aGithubString [

	SBTreeSitter
		compile: ('{1}

	<apicall: SBTSLanguageStruct* tree_sitter_{1} () module: ''tree-sitter-{1}''>
	^ SBMetaBlockFactory tryPatchLibrary: {2} name: ''{1}'' context: thisContext' format: {aName. aGithubString storeString})
		classified: 'ffi languages'
]

{ #category : #'loading - helper' }
SBTSLanguage class >> generateGrammarClassFrom: path name: aString github: anotherString [

	| grammarFile highlightsFile |
	[ | class |
		grammarFile := path / 'src' / 'grammar.json' in: [:file | file exists ifTrue: [FileStream readOnlyFileNamed: file fullName] ifFalse: [nil]].
		highlightsFile := path / 'queries' / 'highlights.scm' in: [:file | file exists ifTrue: [FileStream readOnlyFileNamed: file fullName] ifFalse: [nil]].
		class := SBTSLanguage
			subclass: ('SB', aString capitalized) asSymbol
			instanceVariableNames: ''
			classVariableNames: ''
			poolDictionaries: ''
			category: 'Sandblocks-', aString capitalized.
		class class
			compile: ('grammarJson

    " https://github.com/{1}/blob/master/src/grammar.json "
    ^ {2}' format: {anotherString. grammarFile contents storeString})
			classified: 'properties'.
		class class
			compile: ('language

    ^ {1}' format: {aString asSymbol storeString})
			classified: 'configuration'.
		class class
			compile: ('rootRuleName

    ^ {1}' format: {class firstRuleName storeString})
			classified: 'configuration'.
		highlightsFile ifNotNil: [:f |
			class class
				compile: ('highlightQuery

    " https://github.com/{1}/blob/master/src/queries/highlights.scm "
    ^ {2}' format: {anotherString. f contents storeString})
				classified: 'properties']] ensure: [
		grammarFile ifNotNil: #close.
		highlightsFile ifNotNil: #close]
]

{ #category : #configuration }
SBTSLanguage class >> grammarJson [

	^ self subclassResponsibility
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> hardLineBreakBetween: aBlock and: anotherBlock [

	(aBlock slot isStatementIn: aBlock parentSandblock) ifTrue: [^ true].
	^ false
]

{ #category : #configuration }
SBTSLanguage class >> highlightQuery [

	^ nil
]

{ #category : #'configuration - semantics' }
SBTSLanguage class >> hoverFor: aBlock do: aClosure blocking: aBoolean [

	
]

{ #category : #configuration }
SBTSLanguage class >> icon [

	^ nil
]

{ #category : #accessing }
SBTSLanguage class >> iconMorph [

	^ self icon ifNotNil: #asMorph ifNil: [SBIcon iconFile]
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> indentMatch: aBlock [

	^ false
]

{ #category : #lifecycle }
SBTSLanguage class >> initialize [

	self allSubclassesDo: #invalidate
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> inputTransitionBlackList [
	"return a list of types that should not be considered during transitions, e.g. the typical C comma operator that just chains multiple expressions and thus yields mostly noise"

	^ #()
]

{ #category : #loading }
SBTSLanguage class >> installFromGitHub: aString [

	| name url |
	url := aString.
	(url beginsWith: 'https://github.com/') ifTrue: [url := url allButFirst: 'https://github.com/' size].
	name := (url regex: 'tree-sitter-(.+)' matchesCollect: [:m | m allButFirst: 'tree-sitter-' size]) first.
	'Importing ', name displayProgressFrom: 1 to: 2 during: [:bar |
		bar value: 1.
		SBTSLanguage loadLanguage: url name: name branch: 'master'.
		bar value: 2].
	
	^ Smalltalk at: ('SB', name capitalized) asSymbol
]

{ #category : #lifecycle }
SBTSLanguage class >> instance [

	^ instance ifNil: [instance := self new]
]

{ #category : #lifecycle }
SBTSLanguage class >> invalidate [

	instance := nil
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> isBlockInlined: aSymbol [

	^ self isBlockInlinedInParent: aSymbol
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> isBlockInlinedInParent: aSymbol [

	^ false
]

{ #category : #configuration }
SBTSLanguage class >> isExpression: aBlock [

	^ false
]

{ #category : #'configuration - declarations' }
SBTSLanguage class >> isIdentifier: aBlock [

	^ aBlock type = 'identifier'
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> isImmutableLabel: aLabelNode [

	^ false
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> isOneStatementPerArtefactFor: aBlock [

	^ false
]

{ #category : #'configuration - declarations' }
SBTSLanguage class >> isScope: aBlock [

	^ aBlock isBlockBody
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> isStatementContainer: aRepeatNode in: aBlock [

	^ aRepeatNode element type = 'statement'
]

{ #category : #configuration }
SBTSLanguage class >> language [

	^ self subclassResponsibility
]

{ #category : #loading }
SBTSLanguage class >> loadLanguage: aGithubString name: aString branch: anotherString [

	| path |
	path := self fetchLibrary: aGithubString branch: anotherString.
	self compileParserIn: path name: aString root: path.
	self generateGrammarClassFrom: path name: aString github: aGithubString.
	self generateFFIMethodFor: aString github: aGithubString
]

{ #category : #loading }
SBTSLanguage class >> loadLanguage: aGithubString name: aString branch: anotherString subpath: aPathString [

	| path subpath |
	path := self fetchLibrary: aGithubString branch: anotherString.
	subpath := path / aPathString.
	self compileParserIn: subpath name: aString root: path.
	self generateGrammarClassFrom: path name: aString github: aGithubString.
	self generateFFIMethodFor: aString github: aGithubString
]

{ #category : #'configuration - semantics' }
SBTSLanguage class >> lspTransportFor: aDirectoryString [

	^ self subclassResponsibility
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> noteUncapturedText [

	^ #('symbol' 'string')
]

{ #category : #'instantiate blocks' }
SBTSLanguage class >> parse: aString [

	^ SBTSFileParser new parse: aString language: self
]

{ #category : #'instantiate blocks' }
SBTSLanguage class >> parseExpression: aString [

	| toplevel |
	toplevel := SBTSFileParser new parse: aString language: self.
	self
		assert: toplevel childSandblocks size = 1
		description: 'More than one child was returned from the parsed expression. Consider using parse: instead.'.
	^ toplevel childSandblocks first
]

{ #category : #'instantiate blocks' }
SBTSLanguage class >> parseToplevel: aString [

	| toplevel |
	toplevel := SBTSFileParser new parse: aString language: self.
	toplevel
		hResizing: #rigid;
		layoutInset: 12;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured.
	^ toplevel
]

{ #category : #configuration }
SBTSLanguage class >> postprocessGrammar: aGrammar [
	"hook for modifying properties of the grammar just after we apply inlining rules etc"

	(self emptyLineSymbol notNil or: [self commentSymbols notEmpty]) ifNotNil: [
		self emptyLineSymbol ifNotNil: [:sym |
			aGrammar rules at: sym put: (SBTSNodeContextSensitiveText new
				factory: aGrammar;
				regexString: '(?!x)x|^$';
				validCheck: [:s :c | false];
				typeMatch: [:type :parser | false])].
		
		aGrammar rules keysAndValuesDo: [:symbol :body | body allElementsDo: [:node | (node isTSRepeat and: [self isStatementContainer: node in: (SBTSNodeSymbol new type: symbol factory: aGrammar)]) ifTrue: [node transformToStatementRepeater]]]]
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> preferNoPopup [

	^ SBTSInputReconcile preferNoPopup
]

{ #category : #configuration }
SBTSLanguage class >> preprocessGrammar: aGrammar [
	"after we inline, _statement is no longer present, so check and mark repeats before processing"
	"hook for modifying properties of the grammar just before we apply inlining rules etc"

	aGrammar allElementsDo: [:node | (node isTSRepeat and: [node element type = #'_statement']) ifTrue: [node transformToStatementRepeater]]
]

{ #category : #lifecycle }
SBTSLanguage class >> rebuild [

	self invalidate.
	^ self instance
]

{ #category : #lifecycle }
SBTSLanguage class >> rebuildAll [

	self allSubclassesDo: [:c | [c rebuild] on: Error do: []]
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> removeIndent: aBlock [

	((aBlock isTextMorph or: [aBlock isStringMorph]) and: [{'}'. ')'. ']'. '>'} includes: aBlock effectiveContents]) ifTrue: [^ true].
	^ false
]

{ #category : #'configuration - declarations' }
SBTSLanguage class >> resolveDeclaration: aBlock [

	self scopesAround: aBlock do: [:scope :declarations |
		declarations
			detect: [:decl | decl contents = aBlock contents]
			ifFound: [:decl | ^ decl block]].
	^ nil
]

{ #category : #configuration }
SBTSLanguage class >> rootRuleName [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSLanguage class >> rule: aSymbol [

	^ self instance grammar bodyNodeForRule: aSymbol
]

{ #category : #accessing }
SBTSLanguage class >> runtime [

	SBTSActiveRuntime value ifNotNil: [:runtime | runtime class language = self ifTrue: [^ runtime]].
	^ self defaultRuntimeClass ifNotNil: [:cl | cl new factory: self]
]

{ #category : #'configuration - declarations' }
SBTSLanguage class >> scopesAround: aBlock do: aClosure [

	| current |
	current := aBlock.
	[current notNil and: [current isTSBlock]] whileTrue: [
		(self isScope: current) ifTrue: [
			aClosure
				value: current
				value: (Array streamContents: [:stream | self declarationsInScope: current do: [:decl | stream nextPut: decl]])].
		current := current parentSandblock]
]

{ #category : #'configuration - semantics' }
SBTSLanguage class >> showHelpFor: aBlock [

	
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> showInsertHints [

	^ true
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> softLineBreakBetween: aBlock and: anotherBlock [

	| firstRepeater secondRepeater |
	firstRepeater := aBlock slot repeater.
	secondRepeater := anotherBlock slot repeater.
	self flag: #fixme.
	"what we want to do is check whether they belong to the same repeater but are of different instances of the repeat"
	(firstRepeater notNil and: [firstRepeater = secondRepeater and: [firstRepeater element isTSSymbol or: [firstRepeater element isTSChoice]]]) ifTrue: [^ true].
	
	anotherBlock submorphIndex > 2 ifTrue: [^ true].
	
	^ false
]

{ #category : #'configuration - layout' }
SBTSLanguage class >> spaceBetween: aBlock and: anotherBlock lastCharacterOfFirst: aCharacter [

	^ (aCharacter isAlphaNumeric or: [aCharacter = $_]) and: [
		anotherBlock firstSourceCharacter
			ifNotNil: [:c | c isAlphaNumeric or: [c = $_]]
			ifNil: [false]]
]

{ #category : #configuration }
SBTSLanguage class >> statementTerminator [

	^ nil
]

{ #category : #'configuration - suggestions' }
SBTSLanguage class >> suggestAlwaysFor: aBlock [

	^ false
]

{ #category : #'configuration - suggestions' }
SBTSLanguage class >> suggestionsFor: aBlock [

	^ #()
]

{ #category : #'configuration - suggestions' }
SBTSLanguage class >> suggestionsForInsert: aCommand [

	^ #()
]

{ #category : #'configuration - editing' }
SBTSLanguage class >> transitionPairs [

	^ #()
]

{ #category : #'loading - helper' }
SBTSLanguage class >> tryPatchLibrary: aGithubString name: aString context: aContext branch: anotherString subpath: aPathString [

	| path library subpath |
	ExternalFunction getLastError = 15 ifFalse: [^ self externalCallFailed].
	Smalltalk platformName = 'Mac OS' ifTrue: [
		aContext method externalLibraryName: 'tree-sitter-', aString, '.so'.
		^ aContext method externalLibraryFunction invoke].
	path := self fetchLibrary: aGithubString branch: anotherString.
	subpath := aPathString ifNotEmpty: [path / aPathString] ifEmpty: [path].
	library := self compileParserIn: subpath name: aString root: path.
	aContext method externalLibraryName: library fullName.
	^ aContext method externalLibraryFunction invoke
]

{ #category : #'instantiate blocks' }
SBTSLanguage class >> unknownFor: aSymbol [

	^ SBTSUnknownBlock new slot: (SBTSSlot with: (SBTSNodeSymbol new type: aSymbol factory: self instance grammar))
]

{ #category : #loading }
SBTSLanguage class >> updateFrom: aGithubString branch: aString [

	| path grammarFile highlightsFile |
	path := self fetchLibrary: aGithubString branch: aString.
	self compileParserIn: path name: self language root: path.
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
	self rebuild.
	UIManager default notify: 'restart squeak to make sure the shared library is reloaded as well'
]

{ #category : #'configuration - declarations' }
SBTSLanguage class >> usagesOf: aBlock do: aClosure [

	(self resolveDeclaration: aBlock) ifNotNil: [:declaration | (self usagesOfDeclaration: declaration) do: [:usage | aClosure value: usage]]
]

{ #category : #'configuration - declarations' }
SBTSLanguage class >> usagesOfDeclaration: aDeclaration [

	self
		scopesAround: aDeclaration
		do: [:scope :declarations | ^ Array streamContents: [:stream | scope allBlocksDo: [:block | (block isTSBlock and: [(self isIdentifier: block) and: [block contents = aDeclaration contents]]) ifTrue: [stream nextPut: block]]]].
	^ #()
]

{ #category : #configuration }
SBTSLanguage class >> validPrefixInputs [

	^ #($[ ${ $()
]

{ #category : #configuration }
SBTSLanguage class >> validSuffixIputs [

	^ #($+ $- $* $/ $% $. $= $< $>)
]

{ #category : #grammar }
SBTSLanguage >> grammar [

	^ grammar
]

{ #category : #'initialize-release' }
SBTSLanguage >> initialize [

	super initialize.
	
	grammar := SBTSGrammar new
		language: self class;
		prepareGrammar: (Json readFrom: self class grammarJson readStream);
		yourself
]
