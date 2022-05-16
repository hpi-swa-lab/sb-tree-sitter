Class {
	#name : #SBMetaBlockFactory,
	#superclass : #Object,
	#instVars : [
		'grammar',
		'templateCache',
		'statementContainerTypes',
		'blockInline',
		'blockInlineInParent',
		'hardLineBreakMatcher',
		'supertypes',
		'name',
		'highlightQuery',
		'rootRuleName',
		'delimitedRules',
		'fullTokens',
		'wordRule',
		'extras',
		'noteUncapturedText',
		'aliases',
		'promotedInlineSymbols',
		'containersOfPromotedInlineSymbols',
		'softLineBreakMatcher',
		'nodesCache',
		'aliasOccurrences',
		'expressionTypes'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #helper }
SBMetaBlockFactory class >> compileParserIn: path name: aString [

	| filename hasScanner |
	filename := 'tree-sitter-', aString, '.so'.
	hasScanner := false.
	self assert: (OSProcess waitForCommand: ('cd {1}; npx -p tree-sitter-cli tree-sitter generate' format: {path fullName})) exitStatus = 0.
	
	((path / 'src' / 'scanner.c') exists or: [(path / 'src' / 'scanner.cc') exists]) ifTrue: [
		self assert: (OSProcess waitForCommand: ('cd {1}; CXXFLAGS="-I./src -fPIC" CFLAGS="-I./src -fPIC" make src/scanner.o' format: {path fullName})) exitStatus = 0.
		hasScanner := true].
	self assert: (OSProcess waitForCommand: ('cd {1}; CXXFLAGS="-I./src -fPIC" CFLAGS="-I./src  -fPIC" make src/parser.o' format: {path fullName})) exitStatus = 0.
	self assert: (OSProcess waitForCommand: ('cd {1}; g++ -shared -fPIC -o tree-sitter-{2}.so src/parser.o {3} -fPIC' format: {path fullName. aString. hasScanner ifTrue: [' src/scanner.o'] ifFalse: ['']})) exitStatus = 0.
	
	(FileDirectory default / filename) exists ifTrue: [(FileDirectory default / filename) delete].
	path / filename copyTo: FileDirectory default.
	
	^ FileDirectory default / ('tree-sitter-{1}.so' format: {aString})
]

{ #category : #helper }
SBMetaBlockFactory class >> fetchLibrary: aGithubString branch: aString [

	^ (MCFetchGithubRepository new
		projectPath: aGithubString
		projectVersion: aString
		repoPath: nil)
			flushForScriptGet;
			directory
]

{ #category : #helper }
SBMetaBlockFactory class >> fetchTreeSitter [

	| path |
	path := self fetchLibrary: 'tree-sitter/tree-sitter' branch: 'master'.
	self assert: (OSProcess waitForCommand: ('cd {1}; make' format: {path fullName})) exitStatus = 0.
	path / 'libtree-sitter.so' copyTo: FileDirectory default.
	^ FileDirectory default / 'libtree-sitter.so'
]

{ #category : #helper }
SBMetaBlockFactory class >> generateFFIMethodFor: aName github: aGithubString [

	SBTreeSitter
		compile: ('{1}

	<apicall: SBTSLanguage* tree_sitter_{1} () module: ''tree-sitter-{1}''>
	^ SBMetaBlockFactory tryPatchLibrary: {2} name: ''{1}'' context: thisContext' format: {aName. aGithubString storeString})
		classified: 'ffi languages'
]

{ #category : #helper }
SBMetaBlockFactory class >> generateGrammarClassFrom: path name: aString github: anotherString [

	| grammarFile highlightsFile |
	[ | class |
		grammarFile := path / 'src' / 'grammar.json' in: [:file | file exists ifTrue: [FileStream readOnlyFileNamed: file fullName] ifFalse: [nil]].
		highlightsFile := path / 'queries' / 'highlights.scm' in: [:file | file exists ifTrue: [FileStream readOnlyFileNamed: file fullName] ifFalse: [nil]].
		
		class := SBGrammarLanguage
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
			classified: 'properties'.
		class class
			compile: ('rootRuleName

    ^ {1}' format: {'self subclassResponsibility'})
			classified: 'properties'.
		
		highlightsFile ifNotNil: [:f |
			class class
				compile: ('highlightQuery

    " https://github.com/{1}/blob/master/src/queries/highlights.scm "
    ^ {2}' format: {anotherString. f contents storeString})
				classified: 'properties']] ensure: [
		grammarFile ifNotNil: #close.
		highlightsFile ifNotNil: #close]
]

{ #category : #languages }
SBMetaBlockFactory class >> loadDefaultLanguage: aString branch: anotherString [

	^ self loadLanguage: 'tree-sitter/tree-sitter-', aString name: aString branch: anotherString
]

{ #category : #languages }
SBMetaBlockFactory class >> loadLanguage: aGithubString name: aString branch: anotherString [

	| path |
	path := self fetchLibrary: aGithubString branch: anotherString.
	self compileParserIn: path name: aString.
	self generateGrammarClassFrom: path name: aString github: aGithubString.
	self generateFFIMethodFor: aString github: aGithubString
]

{ #category : #'block deduplication' }
SBMetaBlockFactory class >> maxRecursionCountOf: aBlock [

	| max maxType |
	" find the maximum number of repeated elements in this block"
	max := 0.
	maxType := nil.
	aBlock allMorphsDo: [:morph |
		morph hasSubmorphs ifFalse: [ | typeCount |
			typeCount := Dictionary new.
			morph allOwnersDo: [:owner | (owner isKindOf: SBInlineBlockSymbol) ifTrue: [typeCount at: owner type put: (typeCount at: owner type ifAbsentPut: [0]) + 1]].
			max := typeCount values max max: max.
			typeCount values max = max ifTrue: [maxType := typeCount associations detectMax: [:m | m value]]]].
	Transcript showln: {aBlock. max. maxType}.
	^ max
]

{ #category : #'block deduplication' }
SBMetaBlockFactory class >> maxSimpleRecursionCountOf: aBlock [

	| typeCount |
	" find the maximum number of repeated elements in this block"
	typeCount := Dictionary new.
	aBlock allMorphsDo: [:morph | (morph isKindOf: SBInlineBlockSymbol) ifTrue: [typeCount at: morph type put: (typeCount at: morph type ifAbsentPut: [0]) + 1]].
	Transcript showln: {aBlock. typeCount associations detectMax: [:assoc | assoc value]}.
	^ typeCount values max
]

{ #category : #'block deduplication' }
SBMetaBlockFactory class >> removeDuplicateChoices: aCollection [

	aCollection size = 1 ifTrue: [^ aCollection].
	
	SBToggledCode comment: '' active: 1 do: {
		[ | min |
			min := aCollection detectMin: [:m | self maxRecursionCountOf: m].
			^ aCollection select: [:m | (self maxRecursionCountOf: m) = (self maxRecursionCountOf: min)]].
		[ | shortest |
			shortest := aCollection detectMin: [:choice | choice lengthOfLeftMostPath].
			^ aCollection select: [:choice |
				choice = shortest or: [ | a b |
					a := choice leftMostRule ownerThatIsA: SBInlineBlockSymbol.
					b := shortest leftMostRule ownerThatIsA: SBInlineBlockSymbol.
					a notNil and: [b notNil and: [a type ~= b type]]]]]}
]

{ #category : #helper }
SBMetaBlockFactory class >> tryPatchLibrary: aGithubString name: aString context: aContext [

	^ self tryPatchLibrary: aGithubString name: aString context: aContext branch: 'master'
]

{ #category : #helper }
SBMetaBlockFactory class >> tryPatchLibrary: aGithubString name: aString context: aContext branch: anotherString [

	| path library |
	ExternalFunction getLastError = 15 ifFalse: [^ self externalCallFailed].
	
	Smalltalk platformName = 'Mac OS' ifTrue: [
		aContext method externalLibraryName: 'tree-sitter-', aString, '.so'.
		^ aContext method externalLibraryFunction invoke].
	
	path := self fetchLibrary: aGithubString branch: anotherString.
	library := self compileParserIn: path name: aString.
	aContext method externalLibraryName: library fullName.
	^ aContext method externalLibraryFunction invoke
]

{ #category : #configuration }
SBMetaBlockFactory >> addDelimitedRules: aCollection [

	(aCollection as: Dictionary) keysAndValuesDo: [:rule :delimiter |
		delimitedRules at: rule put: (delimitedRules
			at: rule
			ifPresent: [:list | list copyWith: delimiter]
			ifAbsent: [{delimiter}])]
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> addIndent: aBlock [

	^ false
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> addParentheses: aBlock [

	^ aBlock compatibleWithType: 'expression'
]

{ #category : #accessing }
SBMetaBlockFactory >> aliasOccurrences [

	^ aliasOccurrences
]

{ #category : #accessing }
SBMetaBlockFactory >> aliases [

	^ aliases
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> allSymbolsProducedBy: anObject on: aStream [

	(#('PREC' 'REPEAT' 'FIELD' 'REPEAT1') includes: anObject type) ifTrue: [^ self allSymbolsProducedBy: anObject content on: aStream].
	(#('STRING' 'PATTERN' 'BLANK') includes: anObject type) ifTrue: [^ self].
	
	anObject type caseOf: {
		['CHOICE'] -> [anObject members do: [:m | self allSymbolsProducedBy: m on: aStream]].
		['SYMBOL'] -> [aStream nextPut: anObject name].
		['ALIAS'] -> [aStream nextPut: anObject value].
		['SEQ'] -> [anObject members do: [:member | self allSymbolsProducedBy: member on: aStream]]}
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> allUsagesOf: aString [

	^ Array streamContents: [:stream | templateCache keysAndValuesDo: [:name :root | root allElementsDo: [:block | block type = aString ifTrue: [stream nextPut: {block. name}]]]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> applyInlining: rule name: aString [

	(rule type = 'SYMBOL' and: [
		(grammar inline includes: rule name) and: [
			SBToggledCode
				comment: ''
				active: 2
				do: {[true]. [(grammar supertypes includes: rule name) not]}]]) ifTrue: [ | inline |
		inline := grammar rules at: rule name.
		SBToggledCode comment: '' active: 1 do: {
			[
				rule removeAll.
				inline keysAndValuesDo: [:k :v | rule at: k put: v]].
			[ | symbols |
				symbols := (Array streamContents: [:stream | self symbolsProducedBy: inline on: stream]) asSet.
				symbols size = 1 ifTrue: [rule name: symbols anyOne] ifFalse: [
					rule
						type: 'CHOICE';
						members: (symbols collect: [:m | JsonObject fromAssociations: {'name' -> m. 'type' -> 'SYMBOL'}] as: Array)]]}.
		^ self].
	
	(rule type = 'SYMBOL' and: [rule name first = $_ and: [(grammar externals noneSatisfy: [:e | e name = rule name]) and: [(grammar supertypes includes: rule name) not]]]) ifTrue: [ | inline |
		inline := grammar rules at: rule name.
		(self includesNonHiddenParts: inline visited: Set new) ifTrue: [
			(delimitedRules includesKey: rule name) ifTrue: [delimitedRules at: aString put: (delimitedRules at: rule name)].
			rule removeAll.
			inline keysAndValuesDo: [:key :val | rule at: key put: val]].
		^ self].
	
	rule content ifNotNil: [:c | self applyInlining: c name: aString].
	rule members ifNotNil: [:c | c do: [:child | self applyInlining: child name: aString]]
]

{ #category : #templates }
SBMetaBlockFactory >> at: aString putTemplate: aBlock [

	templateCache at: aString put: aBlock
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> autofixExternals [

	| externals |
	externals := (grammar externals select: [:rule | rule type = 'SYMBOL']) collect: #name.
	
	externals do: [:external |
		self grammar rules at: external ifAbsent: [
			grammar rules keysAndValuesDo: [:name :rule |
				self
					traverse: rule
					detect: [:obj | obj type = 'ALIAS' and: obj content name = external]
					ifFound: [:obj |
						self grammar rules
							at: external
							put: (JsonObject fromAssociations: {'type' -> 'STRING'. 'value' -> obj value})]
					ifNone: []]]].
	
	(grammar externals select: [:rule | rule type = 'STRING']) do: [:external |
		self grammar rules at: external value ifAbsent: [
			self grammar rules
				at: external value
				put: (JsonObject fromAssociations: {'type' -> 'STRING'. 'value' -> external value})]].
	
	(externals reject: [:external | grammar rules includesKey: external]) ifNotEmpty: [:missing | UIManager default inform: 'Missing declarations for: ', (missing joinSeparatedBy: ', ')]
]

{ #category : #configuration }
SBMetaBlockFactory >> blockInline: aCollection [

	blockInline := Set newFrom: aCollection
]

{ #category : #configuration }
SBMetaBlockFactory >> blockInlineInParent: aCollection [

	blockInline addAll: aCollection.
	blockInlineInParent addAll: aCollection
]

{ #category : #helper }
SBMetaBlockFactory >> bodyNodeForRule: aString [

	^ self bodyNodeForRule: aString ifAbsent: [^ self error: 'no such rule: ', aString]
]

{ #category : #helper }
SBMetaBlockFactory >> bodyNodeForRule: aString ifAbsent: aBlock [

	((self inlinedRules includes: aString) and: [(self supertypes includes: aString) not]) ifTrue: [^ aBlock value].
	
	nodesCache ifNil: [nodesCache := Dictionary new].
	^ nodesCache
		at: aString
		ifAbsentPut: [self buildNodesFor: (grammar rules at: aString ifAbsent: [^ aBlock value])]
]

{ #category : #actions }
SBMetaBlockFactory >> browseImplementorsFor: aBlock [

	
]

{ #category : #helper }
SBMetaBlockFactory >> buildBlocksFor: anObject [

	'FIELD' = anObject type ifTrue: [
		^ (self buildBlocksFor: anObject content)
			field: anObject name;
			yourself].
	
	'ALIAS' = anObject type ifTrue: [
		^ (self buildBlocksFor: anObject content)
			alias: (anObject at: #value);
			yourself].
	
	(self unpackTypes includes: anObject type) ifTrue: [^ self buildBlocksFor: anObject content].
	
	'STRING' = anObject type ifTrue: [
		^ SBInlineBlockLabel new
			label: anObject value;
			factory: self].
	
	(#('PATTERN' 'TOKEN' 'IMMEDIATE_TOKEN') includes: anObject type) ifTrue: [
		^ SBInlineBlockText new
			regexString: (self buildRegexString: anObject);
			hint: (anObject at: #name);
			factory: self].
	
	'SYMBOL' = anObject type ifTrue: [
		^ SBInlineBlockSymbol new
			type: anObject name factory: self;
			hint: (anObject at: #name);
			factory: self].
	
	'REPEAT' = anObject type ifTrue: [
		^ SBInlineBlockRepeat new
			multiple: true required: false element: (self buildBlocksFor: anObject content);
			factory: self].
	
	'REPEAT1' = anObject type ifTrue: [
		^ SBInlineBlockRepeat new
			multiple: true required: true element: (self buildBlocksFor: anObject content);
			factory: self].
	
	'CHOICE' = anObject type ifTrue: [
		(anObject members size = 2 and: [anObject members second type = 'BLANK'])
			ifTrue: [^ SBInlineBlockRepeat new
				multiple: false
					required: false
					element: (self buildBlocksFor: anObject members first);
				hint: (anObject at: #name);
				factory: self]
			ifFalse: [ ^ SBInlineBlockChoice new
				alternatives: (anObject members collect: [:member | self buildBlocksFor: member]);
				hint: (anObject at: #name);
				factory: self]].
	
	'SEQ' = anObject type ifTrue: [
		^ SBInlineBlockSequence new
			factory: self;
			elements: (anObject members collect: [:member | self buildBlocksFor: member])].
	
	self assert: false
]

{ #category : #helper }
SBMetaBlockFactory >> buildNodesFor: anObject [

	anObject type = 'FIELD' ifTrue: [
		^ (self buildNodesFor: anObject content)
			field: anObject name;
			yourself].
	
	anObject type = 'ALIAS' ifTrue: [
		^ SBTSNodeAlias new
			alias: (anObject at: #value);
			element: (self buildNodesFor: anObject content);
			factory: self;
			yourself].
	
	(#('PREC_RIGHT' 'PREC_LEFT' 'PREC_DYNAMIC' 'PREC') includes: anObject type) ifTrue: [
		^ SBTSNodePrecedence new
			element: (self buildNodesFor: anObject content);
			precedence: anObject type;
			value: (anObject at: 'value');
			factory: self].
	
	(#('STRING') includes: anObject type) ifTrue: [
		^ SBTSNodeLabel new
			label: anObject value;
			factory: self].
	
	(#('PATTERN' 'TOKEN' 'IMMEDIATE_TOKEN') includes: anObject type) ifTrue: [
		^ SBTSNodeText new
			regexString: (self buildRegexString: anObject);
			factory: self].
	
	(#('SYMBOL') includes: anObject type) ifTrue: [
		^ SBTSNodeSymbol new
			type: anObject name factory: self;
			factory: self].
	
	'REPEAT' = anObject type ifTrue: [
		^ SBTSNodeRepeat new
			multiple: true required: false element: (self buildNodesFor: anObject content);
			factory: self].
	
	'REPEAT1' = anObject type ifTrue: [
		^ SBTSNodeRepeat new
			multiple: true required: true element: (self buildNodesFor: anObject content);
			factory: self].
	
	'CHOICE' = anObject type ifTrue: [
		(anObject members size = 2 and: [anObject members second type = 'BLANK']) ifTrue: [
			^ SBTSNodeRepeat new
				multiple: false required: false element: (self buildNodesFor: anObject members first);
				factory: self].
		
		^ SBTSNodeChoice new
			alternatives: (anObject members collect: [:member | self buildNodesFor: member]);
			factory: self].
	
	'SEQ' = anObject type ifTrue: [
		^ SBTSNodeSeq new
			factory: self;
			elements: (anObject members collect: [:member | self buildNodesFor: member])].
	
	self assert: false
]

{ #category : #helper }
SBMetaBlockFactory >> buildRegex: anObject on: aStream [

	(self unpackTypes includes: (anObject at: #type)) ifTrue: [^ self buildRegex: anObject content on: aStream].
	
	(anObject at: #type) caseOf: {
		['TOKEN'] -> [self buildRegex: anObject content on: aStream].
		['IMMEDIATE_TOKEN'] -> [self buildRegex: anObject content on: aStream].
		['REPEAT'] -> [
			aStream nextPut: $(.
			self buildRegex: anObject content on: aStream.
			aStream nextPut: $).
			aStream nextPut: $*].
		['REPEAT1'] -> [
			aStream nextPut: $(.
			self buildRegex: anObject content on: aStream.
			aStream nextPut: $).
			aStream nextPut: $+].
		['PATTERN'] -> [
			aStream nextPut: $(.
			aStream nextPutAll: (anObject at: #value).
			aStream nextPut: $)].
		['CHOICE'] -> [
			aStream nextPut: $(.
			anObject members
				do: [:c | self buildRegex: c on: aStream]
				separatedBy: [aStream nextPut: $|].
			aStream nextPut: $)].
		['SEQ'] -> [anObject members do: [:c | self buildRegex: c on: aStream]].
		['STRING'] -> [
			aStream nextPut: $(.
			aStream nextPutAll: (self escapeStringForRegex: (anObject at: #value)).
			aStream nextPut: $)].
		['BLANK'] -> []}
]

{ #category : #helper }
SBMetaBlockFactory >> buildRegexString: rule [

	| s |
	s := '' writeStream.
	self buildRegex: rule on: s.
	^ ((s contents copyReplaceAll: '\p{XID_Start}' with: 'A-Za-z')
		copyReplaceAll: '\p{XID_Continue}'
		with: 'A-Za-z0-9')
		copyReplaceAll: ':'
		with: '\:'
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> checkStructure: anObject [

	self assert: (anObject type ~= 'CHOICE' or: [anObject members size > 0]).
	
	anObject content ifNotNil: [:c | self checkStructure: c].
	anObject members ifNotNil: [:c | c do: [:m | self checkStructure: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> cleanGrammar [

	SBToggledCode comment: '' active: 1 do: {[self autofixExternals]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self removeExternals: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules keysAndValuesDo: [:name :rule | self removeHiddenTerminals: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self unwrapSingleChoices: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules keysAndValuesDo: [:name :rule | self removeHiddenTerminals: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self simplifyList: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self mergeRepeats: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules keysAndValuesDo: [:name :rule | self flattenSeparatedList: rule name: name]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules keysAndValuesDo: [:name :rule | self applyInlining: rule name: name]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules keysAndValuesDo: [:name :rule | self applyInlining: rule name: name]]}.
	SBToggledCode comment: '' active: 1 do: {
		[" depends on inlining, requires removing blanks (hidden terminals) "
		grammar rules keysAndValuesDo: [:name :rule | delimitedRules at: name ifPresent: [:r | self removeMarkedDelimiters: rule rule: name]]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self mergeRedundantRepeats: rule]]}.
	SBToggledCode comment: '' active: 1 do: {
		[
			grammar rules keysAndValuesDo: [:name :rule |
				SBToggledCode
					comment: ''
					active: 1
					do: {[self noteAliases: rule name: name]. [self removeAliases: rule]}]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self unwrapSingleChoices: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self mergeOptionalRepeat: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self removeDuplicateAlternatives: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self mergeNestedChoices: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules do: [:rule | self mergeAdjacentOptions: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[grammar rules keysAndValuesDo: [:name :rule | self removeHiddenTerminals: rule]]}.
	grammar rules do: [:rule | self checkStructure: rule]
]

{ #category : #testing }
SBMetaBlockFactory >> containsPromotedInlineSymbol: aString [

	^ containersOfPromotedInlineSymbols includes: aString
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> deepCompare: anObject to: anotherObject [

	anObject associationsDo: [:assoc | | obj |
		obj := anotherObject at: assoc key ifAbsent: [^ false].
		((obj isDictionary and: [assoc value isDictionary])
			ifTrue: [self deepCompare: assoc value to: obj]
			ifFalse: [obj = assoc value]) ifFalse: [^ false]].
	^ true
]

{ #category : #configuration }
SBMetaBlockFactory >> delimitedRules [

	^ delimitedRules
]

{ #category : #helper }
SBMetaBlockFactory >> escapeStringForRegex: aString [

	^ aString copyWithRegex: '[.*+?^${}()|\[\]\\]' matchesTranslatedUsing: [:m | '\', m]
]

{ #category : #accessing }
SBMetaBlockFactory >> expressionTypes [

	^ expressionTypes ifNil: [#()]
]

{ #category : #configuration }
SBMetaBlockFactory >> expressionTypes: aCollection [

	expressionTypes := aCollection
]

{ #category : #accessing }
SBMetaBlockFactory >> extras [

	^ extras
]

{ #category : #accessing }
SBMetaBlockFactory >> extras: aCollection [
	" a list of rules that are considered extras in TS, meaning comments and whitespaces "

	extras := aCollection
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> findBlockInlineCandidates [
	" unit productions, A -> B, or A -> B | C | D "

	templateCache keysAndValuesDo: [:rule :root |
		(((grammar at: #inline) includes: rule) or: [((grammar at: #supertypes) includes: rule) or: [rule first = $_]]) ifFalse: [
			root
				allElementsDetect: [:block | ((block isKindOf: SBInlineBlockSymbol) or: [block isKindOf: SBInlineBlockChoice]) not]
				ifFound: [:block | ]
				ifNone: [blockInline add: name]]].
	
	" seq inside seq "
	templateCache keysAndValuesDo: [:name :root |
		root allElementsDo: [:block |
			(block isKindOf: SBInlineBlockSequence) ifTrue: [
				block elementsDo: [:element |
					((element isKindOf: SBInlineBlockSymbol) and: [ | usages |
						usages := self allUsagesOf: element type.
						usages notEmpty and: [
							usages allSatisfy: [:pair | | parent |
								parent := pair first parentElementIn: (self getTemplate: pair second).
								(parent isKindOf: SBInlineBlockSequence) or: [parent isNil]]]]) ifTrue: [blockInline add: element type]]]]].
	
	blockInline remove: self rootRuleName ifAbsent: []
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> flattenSeparatedList: anObject name: aString [

	| looksLikeSepList looksLikeOptionalSep |
	looksLikeSepList := [:obj | obj type = 'SEQ' and: [obj members size = 2 and: [obj members second type = 'REPEAT' and: [obj members second content type = 'SEQ' and: [self deepCompare: obj members first to: obj members second content members second]]]]].
	looksLikeOptionalSep := [:obj | obj type = 'CHOICE' and: [obj members second type = 'BLANK' and: [obj members first type = 'STRING']]].
	
	" seq(seq(rule, repeat(seq(separator, rule))), (separator|blank)) "
	(anObject type = 'SEQ' and: [(looksLikeSepList value: anObject members first) and: [looksLikeOptionalSep value: anObject members second]]) ifTrue: [
		self addDelimitedRules: {aString -> anObject members second members first value}.
		^ anObject
			type: 'REPEAT';
			content: anObject members first members first;
			removeKey: #members].
	
	" seq(rule, repeat(seq(separator, rule))) "
	(looksLikeSepList value: anObject) ifTrue: [
		self addDelimitedRules: {aString -> anObject members second content members first value}.
		^ anObject
			type: 'REPEAT1';
			content: anObject members first;
			removeKey: #members].
	
	anObject content ifNotNil: [:c | self flattenSeparatedList: c name: aString].
	anObject members ifNotNil: [:c | c do: [:m | self flattenSeparatedList: m name: aString]]
]

{ #category : #helper }
SBMetaBlockFactory >> fullTokensInclude: aString [

	templateCache do: [:rule | rule allElementsDo: [:m | ((m isKindOf: SBInlineBlockLabel) and: [aString = m label]) ifTrue: [^ true]]].
	^ false
]

{ #category : #templates }
SBMetaBlockFactory >> getTemplate: aTypeString [

	^ self getTemplate: aTypeString ifAbsent: [self assert: false]
]

{ #category : #templates }
SBMetaBlockFactory >> getTemplate: aTypeString ifAbsent: aBlock [

	((self inlinedRules includes: aTypeString) and: [self aliases anySatisfy: [:pair | pair name = aTypeString]]) ifTrue: [^ 'ALIAS'].
	
	^ templateCache at: aTypeString ifAbsent: [ | rule |
		rule := grammar rules at: aTypeString ifAbsent: [
			(self aliases anySatisfy: [:pair | pair name = aTypeString]) ifTrue: [^ 'ALIAS'].
			^ aBlock value].
		
		" reserve spot in case of recursion "
		templateCache at: aTypeString put: nil.
		
		templateCache at: aTypeString put: (self buildBlocksFor: rule)]
]

{ #category : #accessing }
SBMetaBlockFactory >> grammar [

	^ grammar
]

{ #category : #accessing }
SBMetaBlockFactory >> grammar: aJsonObject [

	grammar := aJsonObject
]

{ #category : #accessing }
SBMetaBlockFactory >> grammarHandler [

	^ SBMetaGrammarHandler new
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> hardLineBreakBetween: aBlock and: anotherBlock [

	aBlock parentSandblock isBlockBody ifTrue: [^ true].
	^ false
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> hardLineBreakMatch: aBlock [

	^ hardLineBreakMatcher ifNotNil: [:b | b value: aBlock] ifNil: [false]
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> hardLineBreakMatchBetween: aBlock and: anotherBlock [

	^ hardLineBreakMatcher ifNotNil: [:b | b value: aBlock] ifNil: [false]
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> hardLineBreakMatcher [

	^ hardLineBreakMatcher
]

{ #category : #configuration }
SBMetaBlockFactory >> hardLineBreakMatcher: aBlock [

	hardLineBreakMatcher := aBlock
]

{ #category : #testing }
SBMetaBlockFactory >> hasHighlight [

	^ highlightQuery notNil
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> highlightFor: aSBBlock [

	^ nil
]

{ #category : #helper }
SBMetaBlockFactory >> highlightFor: aSBBlock do: aBlock [
]

{ #category : #accessing }
SBMetaBlockFactory >> highlightQuery [

	^ highlightQuery
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> ignoreExternals: aCollection [

	aCollection do: [:name |
		self grammar rules
			at: name
			put: (JsonObject fromAssociations: {'type' -> 'STRING'. 'value' -> ''})]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> includesNonHiddenParts: anObject visited: aCollection [

	(#('PREC' 'PREC_DYNAMIC' 'PREC_LEFT' 'PREC_RIGHT' 'REPEAT' 'FIELD' 'REPEAT1') includes: anObject type) ifTrue: [^ self includesNonHiddenParts: anObject content visited: aCollection].
	(#('STRING' 'PATTERN' 'TOKEN' 'IMMEDIATE_TOKEN') includes: anObject type) ifTrue: [^ true].
	'BLANK' = anObject type ifTrue: [^ false].
	
	^ anObject type caseOf: {
		['CHOICE'] -> [anObject members anySatisfy: [:m | self includesNonHiddenParts: m visited: aCollection]].
		['SYMBOL'] -> [
			anObject name first ~= $_ ifTrue: [^ true].
			(aCollection includes: anObject name) ifTrue: [false] ifFalse: [
				aCollection add: anObject name.
				self includesNonHiddenParts: (grammar rules at: anObject name) visited: aCollection]].
		['ALIAS'] -> [
			anObject value first ~= $_ ifTrue: [^ true].
			(aCollection includes: anObject value) ifTrue: [false] ifFalse: [
				aCollection add: anObject value.
				grammar rules
					at: anObject value
					ifPresent: [:r | self includesNonHiddenParts: r visited: aCollection]
					ifAbsent: [false]]].
		['SEQ'] -> [anObject members anySatisfy: [:member | self includesNonHiddenParts: member visited: aCollection]]}
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> indentMatch: aBlock [

	^ false
]

{ #category : #'initialize-release' }
SBMetaBlockFactory >> initialize [

	super initialize.
	
	templateCache := Dictionary new.
	aliases := OrderedCollection new.
	aliasOccurrences := OrderedCollection new.
	blockInline := Set new.
	blockInlineInParent := Set new.
	statementContainerTypes := {}.
	promotedInlineSymbols := OrderedCollection new.
	containersOfPromotedInlineSymbols := OrderedCollection new.
	supertypes := {}.
	noteUncapturedText := #().
	hardLineBreakMatcher := [:block | false].
	delimitedRules := Dictionary new
]

{ #category : #accessing }
SBMetaBlockFactory >> inlinedRules [

	^ (self grammar ifNotNil: [:g | g at: 'inline']) ifNil: [#()]
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> inputTransitionBlackList [
	"return a list of types that should not be considered during transitions, e.g. the typical C comma operator that just chains multiple expressions and thus yields mostly noise"

	^ #()
]

{ #category : #templates }
SBMetaBlockFactory >> instantiateTemplate: aString [

	^ (self getTemplate: aString) buildEmpty buildDefault factory: self
]

{ #category : #templates }
SBMetaBlockFactory >> instantiateToplevel: aString [

	^ SBInlineBlockSymbol new
		type: aString factory: self block: (self instantiateTemplate: aString);
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator new;
		hResizing: #rigid;
		updateAllHighlights
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> isBlockInlined: aTypeString [

	^ blockInline includes: aTypeString
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> isBlockInlinedInParent: aTypeString [

	^ blockInlineInParent includes: aTypeString
]

{ #category : #testing }
SBMetaBlockFactory >> isImmutableLabel: aLabelNode [

	^ #(')' ']' '}' '>') includes: aLabelNode label
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> isStatementContainer: aString [

	^ statementContainerTypes includes: aString
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> isSuperType: aTypeString [

	^ self supertypes includes: aTypeString
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> mergeAdjacentOptions: anObject [
	" look for (element | element*) and change to element+ "

	anObject type = 'CHOICE' ifTrue: [
		anObject members copy do: [:alt |
			((alt type beginsWith: 'REPEAT') and: [alt content type = 'SYMBOL']) ifTrue: [
				anObject members do: [:otherAlt |
					(otherAlt type = 'SYMBOL' and: [alt content name = otherAlt name]) ifTrue: [
						alt type: 'REPEAT1'.
						anObject members: (anObject members copyWithout: otherAlt)]]]]].
	
	anObject content ifNotNil: [:c | self mergeNestedChoices: c].
	anObject members ifNotNil: [anObject members do: [:m | self mergeNestedChoices: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> mergeNestedChoices: anObject [
	" (a | (b | c)) -> (a | b | c) "

	anObject type = 'CHOICE' ifTrue: [
		(anObject members noneSatisfy: [:m | m type = 'BLANK']) ifTrue: [
			anObject members: (Array streamContents: [:stream |
				anObject members do: [:nested |
					(nested type = 'CHOICE' and: [nested members noneSatisfy: [:m | m type = 'BLANK']])
						ifTrue: [stream nextPutAll: nested members]
						ifFalse: [stream nextPut: nested]]])]].
	
	anObject content ifNotNil: [:c | self mergeNestedChoices: c].
	anObject members ifNotNil: [anObject members do: [:m | self mergeNestedChoices: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> mergeOptionalRepeat: anObject [

	(anObject type = 'CHOICE' and: [anObject members size = 2 and: [(anObject members first type beginsWith: 'REPEAT') and: [anObject members second type = 'BLANK']]]) ifTrue: [ | copyFrom |
		copyFrom := anObject members first.
		anObject removeAll.
		copyFrom keysAndValuesDo: [:key :val | anObject at: key put: val].
		anObject type: 'REPEAT'].
	
	((anObject type beginsWith: 'REPEAT') and: [anObject content type = 'CHOICE' and: [anObject content members size = 2 and: [anObject content members second type = 'BLANK']]]) ifTrue: [ | copyFrom |
		copyFrom := anObject content members first.
		anObject removeAll.
		anObject content: copyFrom.
		anObject type: 'REPEAT'].
	
	anObject content ifNotNil: [:c | self mergeOptionalRepeat: c].
	anObject members ifNotNil: [anObject members do: [:m | self mergeOptionalRepeat: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> mergeRedundantRepeats: anObject [
	" (a* | b+)* -> (a | b)* "

	(anObject type = 'REPEAT' and: [anObject content type = 'CHOICE']) ifTrue: [
		anObject content members do: [:m |
			(m type = 'REPEAT' or: [m type = 'REPEAT1']) ifTrue: [ | copyFrom |
				copyFrom := m content.
				m removeAll.
				copyFrom keysAndValuesDo: [:key :val | m at: key put: val]]]].
	
	anObject content ifNotNil: [:c | self mergeRedundantRepeats: c].
	anObject members ifNotNil: [anObject members do: [:m | self mergeRedundantRepeats: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> mergeRepeats: anObject [

	(anObject type = 'SEQ' and: [anObject members size = 2 and: [anObject members first type = 'SYMBOL' and: [(anObject members last type = 'REPEAT' and: [anObject members last content type = 'SYMBOL']) and: [anObject members last content name = anObject members first name]]]]) ifTrue: [ | copyFrom |
		copyFrom := anObject members last.
		anObject removeAll.
		copyFrom keysAndValuesDo: [:key :val | anObject at: key put: val].
		anObject type: 'REPEAT1'].
	
	
	anObject content ifNotNil: [:c | self mergeRepeats: c].
	anObject members ifNotNil: [anObject members do: [:m | self mergeRepeats: m]]
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> name [

	^ name
]

{ #category : #accessing }
SBMetaBlockFactory >> name: aSymbol preprocess: aBlock postprocess: anotherBlock grammar: aString highlight: anotherString [

	grammar := Json readFrom: aString readStream.
	self supertypes: grammar supertypes.
	name := aSymbol.
	highlightQuery := SBTSQuery new prepare: anotherString.
	extras := grammar extras
		select: [:rule | rule type = 'SYMBOL']
		thenCollect: [:rule | rule name].
	self wordRule: grammar word.
	
	aBlock cull: self.
	self cleanGrammar.
	anotherBlock cull: self.
	
	" make sure all rules are in the cache "
	grammar rules keysAndValuesDo: [:name :r | self getTemplate: name]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> noteAliases: anObject name: aString [

	anObject type = 'ALIAS' ifTrue: [
		aliases add: (SBTSAlias new
			name: anObject value;
			object: (self buildBlocksFor: anObject);
			parentType: aString).
		aliasOccurrences add: (SBTSAlias new
			name: anObject value;
			object: (self buildNodesFor: anObject);
			parentType: aString)].
	
	anObject content ifNotNil: [:c | self noteAliases: c name: aString].
	anObject members ifNotNil: [:c | c do: [:m | self noteAliases: m name: aString]]
]

{ #category : #configuration }
SBMetaBlockFactory >> noteUncapturedText [

	^ noteUncapturedText
]

{ #category : #configuration }
SBMetaBlockFactory >> noteUncapturedText: aCollection [

	noteUncapturedText := aCollection
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> palettesFor: aBlock [

	^ #()
]

{ #category : #templates }
SBMetaBlockFactory >> parse: aString [

	^ SBTreeSitter new parse: aString language: name factory: self
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> promotedInlineSymbols [

	^ promotedInlineSymbols
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeAliases: anObject [

	SBToggledCode comment: '' active: 1 do: {
		[
			anObject type = 'ALIAS' ifTrue: [ | copyFrom |
				" how to get parentType? "
				self flag: #fixme.
				aliases add: (SBTSAlias new
					name: anObject value;
					object: anObject content veryDeepCopy;
					parentType: nil).
				
				copyFrom := anObject content.
				anObject removeAll.
				copyFrom keysAndValuesDo: [:key :val | anObject at: key put: val].
				^ self]].
		[
			anObject type = 'ALIAS' ifTrue: [
				anObject type: 'SYMBOL'.
				anObject name: anObject value.
				anObject removeKey: 'value'.
				anObject removeKey: 'named'.
				anObject removeKey: 'content'.
				^ self]]}.
	
	anObject content ifNotNil: [:c | self removeAliases: c].
	anObject members ifNotNil: [:c | c do: [:m | self removeAliases: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeDuplicateAlternatives: anObject [
	" TODO: only removes SYMBOL duplicates "

	(anObject type = 'CHOICE' and: [anObject members allSatisfy: [:m | m type = 'SYMBOL']]) ifTrue: [ | symbols |
		symbols := anObject members collect: #name.
		symbols size ~= symbols asSet size ifTrue: [
			anObject members: anObject members withoutDuplicates]].
	anObject content ifNotNil: [self removeDuplicateAlternatives: anObject content].
	anObject members ifNotNil: [anObject members do: [:m | self removeDuplicateAlternatives: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeExternals: anObject [

	anObject content ifNotNil: [:c | self removeExternals: c].
	anObject members ifNotNil: [
		anObject members: (anObject members copyWithoutAll: (Array streamContents: [:stream | anObject members do: [:member | (member type = 'SYMBOL' and: [(grammar externals anySatisfy: [:external | external name = member name]) and: [((grammar at: #inline) includes: member name) not and: [(grammar rules includesKey: member name) not]]]) ifTrue: [stream nextPut: member]]])).
		anObject members do: [:m | self removeExternals: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeHiddenTerminals: anObject [

	anObject content ifNotNil: [:c | self removeHiddenTerminals: c].
	anObject members ifNotNil: [
		anObject members: (anObject members copyWithoutAll: (Array streamContents: [:stream | anObject members do: [:member | ((member type = 'SYMBOL' and: [(self includesNonHiddenParts: member visited: Set new) not]) or: [anObject type = 'SEQ' and: [member type = 'BLANK']]) ifTrue: [stream nextPut: member]]])).
		anObject members do: [:m | self removeHiddenTerminals: m]]
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> removeIndent: aBlock [

	^ false
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeMarkedDelimiters: anObject rule: aString [
	" (a delim) -> (a) "

	anObject content ifNotNil: [:c | self removeMarkedDelimiters: c rule: aString].
	anObject members ifNotNil: [
		anObject members: (anObject members copyWithoutAll: (Array streamContents: [:stream | anObject members do: [:member | (member type = 'STRING' and: [(delimitedRules at: aString) includes: member value]) ifTrue: [stream nextPut: member]]])).
		anObject members do: [:m | self removeMarkedDelimiters: m rule: aString]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeOptionalString: aString in: anObject [

	(anObject type = 'SEQ' and: [
		anObject members last type = 'CHOICE' and: [ | choices |
			choices := anObject members last members.
			choices size = 2 and: [choices second type = 'BLANK' and: [choices first type = 'STRING' and: [choices first value = aString]]]]]) ifTrue: [
		anObject members size = 2
			ifTrue: [anObject members last members: (anObject members last members copyWithout: anObject members last members last)]
			ifFalse: [ | copyFrom |
				copyFrom := anObject members first.
				anObject removeAll.
				copyFrom keysAndValuesDo: [:key :value | anObject at: key put: value]]].
	anObject content ifNotNil: [:c | self removeOptionalString: aString in: c].
	anObject members ifNotNil: [:c | c do: [:m | self removeOptionalString: aString in: m]]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeSymbol: aString [

	self grammar externals: (self grammar externals reject: [:ext | ext name = aString]).
	self grammar rules do: [:rule | self removeSymbol: aString in: rule]
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> removeSymbol: aString in: anObject [

	anObject content ifNotNil: [:c | self removeSymbol: aString in: c].
	anObject members ifNotNil: [
		anObject members: (anObject members copyWithoutAll: (Array streamContents: [:stream | anObject members do: [:member | (member type = 'SYMBOL' and: [aString = member name]) ifTrue: [stream nextPut: member]]])).
		anObject members do: [:m | self removeSymbol: aString in: m]]
]

{ #category : #helper }
SBMetaBlockFactory >> renameSymbol: aString to: anotherString [

	| affectedRules |
	affectedRules := Array streamContents: [:stream |
		self grammar rules keysAndValuesDo: [:name :rule |
			self traverse: rule do: [:obj |
				(obj type = 'SYMBOL' and: [obj name = aString]) ifTrue: [
					obj name: anotherString.
					stream nextPut: name]]]].
	self grammar rules at: anotherString put: (self grammar rules at: aString).
	self grammar rules removeKey: aString.
	
	(aString first = $_ and: [anotherString first ~= $_]) ifTrue: [
		promotedInlineSymbols add: anotherString.
		containersOfPromotedInlineSymbols addAll: affectedRules]
]

{ #category : #accessing }
SBMetaBlockFactory >> rootRuleName [

	^ rootRuleName
]

{ #category : #accessing }
SBMetaBlockFactory >> rootRuleName: aString [

	rootRuleName := aString
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> rule: aRule inlineIn: anObject [

	(anObject type = 'SYMBOL' and: [anObject name = aRule]) ifTrue: [ | copyFrom |
		copyFrom := grammar rules at: aRule.
		anObject removeAll.
		copyFrom keysAndValuesDo: [:key :val | anObject at: key put: val veryDeepCopy].
		^ self].
	
	anObject content ifNotNil: [:c | self rule: aRule inlineIn: c].
	anObject members ifNotNil: [anObject members do: [:m | self rule: aRule inlineIn: m]]
]

{ #category : #accessing }
SBMetaBlockFactory >> rulesDo: aBlock [

	self grammar rules keysAndValuesDo: [:name :rule | aBlock cull: rule cull: name]
]

{ #category : #accessing }
SBMetaBlockFactory >> runtime [

	^ nil
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> separatorRule [

	^ self wordRule
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> shouldBlockInline: aTypeString [

	^ (self isSuperType: aTypeString) or: [blockInline includes: aTypeString]
]

{ #category : #testing }
SBMetaBlockFactory >> shouldSkipParsing: aTypeString in: aParentTypeString cursor: aCursor [

	^ (self delimitedRules
		at: aParentTypeString
		ifPresent: [:delims | delims includes: aTypeString]
		ifAbsent: [false]) or: [self extras includes: aTypeString]
]

{ #category : #actions }
SBMetaBlockFactory >> showHelpFor: aBlock [

	
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> simplifyList: anObject [
	" make a*? to a* "

	(anObject type = 'CHOICE' and: [anObject members size = 2 and: [anObject members last type = 'BLANK' and: [anObject members first type = 'REPEAT']]]) ifTrue: [ | copyFrom |
		copyFrom := anObject members first.
		anObject removeAll.
		copyFrom keysAndValuesDo: [:key :val | anObject at: key put: val]].
	
	anObject content ifNotNil: [:c | self simplifyList: c].
	anObject members ifNotNil: [anObject members do: [:m | self simplifyList: m]]
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> softLineBreakBetween: aBlock and: anotherBlock [

	| firstRepeater secondRepeater |
	firstRepeater := aBlock slot repeater.
	secondRepeater := anotherBlock slot repeater.
	self flag: #fixme.
	"what we want to do is check whether they belong to the same repeater but are of different instances of the repeat"
	(firstRepeater notNil and: [firstRepeater = secondRepeater and: [firstRepeater element isTSSymbol or: [firstRepeater element isTSChoice]]]) ifTrue: [^ true].
	^ false
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> softLineBreakMatchBetween: aBlock and: anotherBlock [

	^ softLineBreakMatcher
		ifNotNil: [:b | b value: aBlock value: anotherBlock]
		ifNil: [false]
]

{ #category : #configuration }
SBMetaBlockFactory >> softLineBreakMatcher: aBlock [

	softLineBreakMatcher := aBlock
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> spaceBetween: aBlock and: anotherBlock [

	^ (aBlock sourceString
		ifNotEmpty: [:s | s last isAlphaNumeric or: [s last = $_]]
		ifEmpty: [false]) and: [
		anotherBlock sourceString
			ifNotEmpty: [:s | s first isAlphaNumeric or: [s first = $_]]
			ifEmpty: [false]]
]

{ #category : #configuration }
SBMetaBlockFactory >> statementContainerTypes: aCollection [

	statementContainerTypes := aCollection
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> suggestionsFor: aBlock [

	^ #()
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> suggestionsForInsert: aCommand [

	^ #()
]

{ #category : #accessing }
SBMetaBlockFactory >> supertypes [

	^ supertypes
]

{ #category : #configuration }
SBMetaBlockFactory >> supertypes: aCollection [

	supertypes := aCollection
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> symbolsProducedBy: anObject on: aStream [

	(#('PREC' 'FIELD') includes: anObject type) ifTrue: [^ self symbolsProducedBy: anObject content on: aStream].
	
	anObject type caseOf: {
		['CHOICE'] -> [anObject members do: [:m | self symbolsProducedBy: m on: aStream]].
		['STRING'] -> [].
		['SYMBOL'] -> [aStream nextPut: anObject name].
		['ALIAS'] -> [aStream nextPut: anObject value].
		['SEQ'] -> [ | nonHidden |
			self assert: (anObject members allSatisfy: [:m | m type = 'SYMBOL']).
			nonHidden := anObject members select: [:m | m name first ~= $_].
			self assert: nonHidden size = 1.
			aStream nextPut: nonHidden first name value]}
]

{ #category : #'as yet unclassified' }
SBMetaBlockFactory >> terminatorFor: anElement on: aStream [

	
]

{ #category : #templates }
SBMetaBlockFactory >> toplevel [

	^ self instantiateToplevel: self rootRuleName
]

{ #category : #configuration }
SBMetaBlockFactory >> transitionPairs [

	^ #()
]

{ #category : #helper }
SBMetaBlockFactory >> traverse: anObject detect: aBlock ifFound: aSuccessBlock ifNone: aFailBlock [

	self traverse: anObject do: [:block | (aBlock value: block) ifTrue: [^ aSuccessBlock value: block]].
	^ aFailBlock value
]

{ #category : #helper }
SBMetaBlockFactory >> traverse: anObject do: aBlock [

	aBlock value: anObject.
	anObject members ifNotNil: [:m | m do: [:member | self traverse: member do: aBlock]].
	anObject content ifNotNil: [:content | self traverse: content do: aBlock]
]

{ #category : #'configuration helpers' }
SBMetaBlockFactory >> type: aRuleName compatibleWith: anotherRuleName [

	(aRuleName isNil and: [anotherRuleName isNil]) ifTrue: [^ true].
	
	anotherRuleName isString ifFalse: [^ anotherRuleName anySatisfy: [:r | self type: aRuleName compatibleWith: r]].
	
	aRuleName = anotherRuleName ifTrue: [^ true].
	
	^ grammar notNil and: [ | template |
		template := self getTemplate: anotherRuleName.
		(template isKindOf: SBInlineBlockChoice) and: [template alternatives anySatisfy: [:t |
				(t isKindOf: SBInlineBlockSymbol)
					ifTrue: [self type: aRuleName compatibleWith: t type]
					ifFalse: [
						t class caseOf: {
							[SBInlineBlockChoice] -> [t alternatives anySatisfy: [:a | (a isKindOf: SBInlineBlockSymbol) and: [self type: aRuleName compatibleWith: a type]]].
							[SBInlineBlockRepeat] -> [(t element isKindOf: SBInlineBlockSymbol) and: [self type: aRuleName compatibleWith: t element type]]
						} otherwise: [false]]]]]
]

{ #category : #helper }
SBMetaBlockFactory >> unpackTypes [

	^ #('PREC_RIGHT' 'PREC_LEFT' 'PREC_DYNAMIC' 'PREC' 'ALIAS' 'FIELD')
]

{ #category : #'grammar clean' }
SBMetaBlockFactory >> unwrapSingleChoices: anObject [
	" (a) -> a, (a* | BLANK) -> a* "

	(((anObject type = 'CHOICE' or: [anObject type = 'SEQ']) and: [anObject members size = 1]) or: [anObject type = 'CHOICE' and: [anObject members size = 2 and: [anObject members first type = 'REPEAT' and: [anObject members second type = 'BLANK']]]]) ifTrue: [ | copyFrom |
		copyFrom := anObject members first.
		anObject removeAll.
		copyFrom keysAndValuesDo: [:key :val | anObject at: key put: val]].
	
	anObject content ifNotNil: [:c | self unwrapSingleChoices: c].
	anObject members ifNotNil: [anObject members do: [:m | self unwrapSingleChoices: m]]
]

{ #category : #testing }
SBMetaBlockFactory >> validDropDestination: aBlock [

	^ true
]

{ #category : #accessing }
SBMetaBlockFactory >> wordRule [

	^ wordRule
]

{ #category : #accessing }
SBMetaBlockFactory >> wordRule: aString [

	aString ifNotNil: [
		wordRule := (self buildRegexString: (grammar rules at: aString)) asRegex]
]
