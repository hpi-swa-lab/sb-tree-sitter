Class {
	#name : #DCBlock,
	#superclass : #SBBlock,
	#instVars : [
		'type',
		'language',
		'range',
		'highlight',
		'field'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #parsing }
DCBlock class >> addUncapturedTextTo: aNode in: aCursor language: aLanguage isLeaf: aBoolean [

	| text start |
	text := aCursor textToNext.
	start := aCursor position.
	text isolateLineBreaks do: [:part |
		part isEmpty ifFalse: [
			part = String cr
				ifTrue: [aNode addMorphBack: (DCLineBreak new range: (SBTSRange start: start size: 1))]
				ifFalse: [
					aNode addMorphBack: (DCText new
						contents: part;
						field: aCursor fieldName;
						range: (SBTSRange start: start size: part size))]].
		start := start + part size].
	aCursor advance: text size.
	
	aBoolean ifTrue: [
		text := aCursor uncapturedText.
		aNode addMorphBack: (DCText new
			contents: text;
			field: aCursor fieldName;
			range: aCursor range)]
]

{ #category : #'text modify' }
DCBlock class >> deleteFrom: aString at: aNumber do: aBlock [

	| new deleted |
	deleted := aString copyFrom: aNumber to: aNumber.
	new := (aString first: aNumber - 1), (aString allButFirst: aNumber).
	^ aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: aNumber - 1;
			oldEndByte: aNumber;
			newEndByte: aNumber - 1;
			bytesToPointsIn: aString new: new)
		value: [:source :block | self insert: deleted in: source at: aNumber do: block]
]

{ #category : #parsing }
DCBlock class >> findChangeRangeFrom: original to: new [

	| start end maxSize |
	start := 1.
	[start <= (original size min: new size) and: [(original at: start) = (new at: start)]] whileTrue: [start := start + 1].
	
	end := 1.
	maxSize := original size min: new size.
	[end <= maxSize and: [maxSize - (end - 1) >= start and: [(original atLast: end) = (new atLast: end)]]] whileTrue: [end := end + 1].
	
	^ SBTSInputEdit new
		startByte: start - 1;
		oldEndByte: original size - (end - 1);
		newEndByte: new size - (end - 1);
		bytesToPointsIn: original new: new
]

{ #category : #parsing }
DCBlock class >> fromCursor: aCursor language: aLanguage [

	^ aCursor isNamed
		ifTrue: [ | node |
			node := DCBlock new
				type: aCursor type;
				field: aCursor fieldName;
				language: aLanguage;
				range: aCursor range.
			
			aCursor gotoFirstChild
				ifTrue: [
					[
						self addUncapturedTextTo: node in: aCursor language: aLanguage isLeaf: false.
						node addMorphBack: (self fromCursor: aCursor language: aLanguage)] doWhileFalse: [aCursor gotoNextSibling].
					self addUncapturedTextTo: node in: aCursor language: aLanguage isLeaf: false.
					aCursor gotoParent]
				ifFalse: [self addUncapturedTextTo: node in: aCursor language: aLanguage isLeaf: true].
			node]
		ifFalse: [
			DCText new
				contents: aCursor text;
				field: aCursor fieldName;
				range: aCursor range]
]

{ #category : #generic }
DCBlock class >> genericAddMarker [
	<query: #shortcut>

	^ {
		[:x | x registerShortcut: #addMarker do: [{[:block | block attachDecorator: SBMarkedDecorator new]}]]}
]

{ #category : #'text modify' }
DCBlock class >> insert: aString in: aContainerString at: aNumber do: aBlock [

	| new |
	new := (aNumber > aContainerString size or: [aContainerString isEmpty])
		ifTrue: [aContainerString, aString]
		ifFalse: [(aContainerString first: aNumber - 1), aString, (aContainerString allButFirst: aNumber - 1)].
	aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: aNumber - 1;
			oldEndByte: aNumber - 1;
			newEndByte: aNumber - 1 + aString size;
			bytesToPointsIn: aContainerString new: new)
		value: [:source :block | self deleteFrom: source at: aNumber do: block]
]

{ #category : #parsing }
DCBlock class >> parse: aString language: aLanguage [

	^ (self parseBlock: aString language: aLanguage)
		layoutInset: 4;
		hResizing: #rigid;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		yourself
]

{ #category : #parsing }
DCBlock class >> parse: aString old: oldBlock language: aLanguage [

	| api oldTree |
	api := SBTreeSitter new.
	oldTree := oldBlock ifNotNil: [
		oldBlock privateTSTreeOrNilDo: [:tsTree |
			api treeEdit: tsTree edit: (self findChangeRangeFrom: oldBlock privateSource to: aString).
			tsTree]].
	
	^ api parseAsCursor: aString language: aLanguage language oldTree: oldTree do: [:cursor :newTree |
		(self
			fromCursor: (SBTSCursorRaw new library: api cursor: cursor factory: aLanguage instance grammar)
			language: aLanguage)
			privateTSTree: newTree;
			privateSource: aString;
			yourself]
]

{ #category : #parsing }
DCBlock class >> parseBlock: aString language: aLanguage [

	^ self parse: aString old: nil language: aLanguage
]

{ #category : #shortcuts }
DCBlock class >> registerShortcuts: aProvider [

	aProvider cmdShortcut: $( do: #wrapInRoundParenthesis.
	aProvider cmdShortcut: ${ do: #wrapInCurlyBraces.
	aProvider cmdShortcut: $[ do: #wrapInSquareBrackets.
	aProvider cmdShortcut: $' do: #wrapInSingleQuotes.
	aProvider cmdShortcut: $" do: #wrapInDoubleQuotes.
	aProvider cmdShortcut: $` do: #wrapInBackticks.
	aProvider shortcut: $M command do: #addMarker
]

{ #category : #'text modify' }
DCBlock class >> replace: aRange in: aContainerString with: aString do: aBlock [

	| new original newLength |
	self
		example: [DCBlock new]
		args: [{SBTSRange start: 3 size: 3. 'abcxxxghi'. 'def'. [:a :b | ]}]
		label: 'example'.
	
	original := aContainerString copyFrom: aRange start index + 1 to: aRange end index.
	newLength := aString size.
	new := (aContainerString first: aRange start index), aString, (aContainerString allButFirst: aRange end index).
	^ aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: aRange start index;
			oldEndByte: aRange end index;
			newEndByte: aRange start index + aString size;
			bytesToPointsIn: aString new: new)
		value: [:source :block | self replace: (aRange withSize: newLength) in: source with: original do: block]
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkBlockWithSelector [

	^ {
		[:x |
			DCQuery
				firstScript: {
					self smalltalkMessageSend.
					{[:b | b type = #symbol]}.
					{[:b | b orParent: #(#'keyword_selector' #'binary_selector' #'unary_selector')]}}
				with: x]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkBrowseClass [
	<query: #shortcut>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x type = #identifier].
		[:x |
			x
				registerShortcut: #browse
				do: [{self smalltalkDeclaration. [:id :decl | decl class = ClassBinding ifTrue: [decl value browse]]}]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkBrowseImplementors [
	<query: #shortcut>

	^ {
		self smalltalkBlockWithSelector.
		[:msg |
			msg registerShortcut: #browseImplementors do: [
				{
					self smalltalkSelector.
					[:selector :message | {#args. selector. self systemNavigation allImplementorsOf: selector asSymbol. message}].
					[:selector :list :message |
						(message sandblockEditor isSingleArtefactView or: [list size > 1])
							ifTrue: [
								(message sandblockEditor model notNil and: [message sandblockEditor model isKindOf: MessageTrace])
									ifTrue: [
										message sandblockEditor model
											browseAllImplementorsOf: selector asSymbol
											requestor: #modelMenu]
									ifFalse: [message systemNavigation browseAllImplementorsOf: selector asSymbol]]
							ifFalse: [message sandblockEditor open: list first compiledMethod]]}]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkBrowseReferences [
	<query: #shortcut>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x type = #identifier].
		[:x |
			x registerShortcut: #browseSenders do: [
				{
					self smalltalkDeclaration.
					[:id :decl |
						decl class = ClassBinding ifTrue: [self systemNavigation browseAllCallsOnClass: decl value].
						decl isString ifTrue: [
							self systemNavigation
								browseAllAccessesTo: decl
								from: x containingArtefact methodClass]]}]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkBrowseReferencesSend [
	<query: #shortcut>

	^ {
		self smalltalkBlockWithSelector.
		[:msg |
			msg registerShortcut: #browseSenders do: [
				{
					self smalltalkSelector.
					[:sel :message | {#args. message. sel. self systemNavigation allCallsOn: sel asSymbol}].
					[:message :sel :calls |
						(message sandblockEditor isSingleArtefactView or: [calls size > 1])
							ifTrue: [
								(message sandblockEditor model notNil and: [message sandblockEditor model isKindOf: MessageTrace])
									ifTrue: [
										message sandblockEditor model
											browseAllCallsOn: sel asSymbol
											requestor: #modelMenu]
									ifFalse: [self systemNavigation browseAllCallsOn: sel asSymbol]]
							ifFalse: [message sandblockEditor open: calls first compiledMethod]]}]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkCheckbox [
	<query: #change>

	^ {
		[:x | false].
		[:x | x language = SBTSSmalltalk].
		[:x | x isReplacement not].
		[:x | {#true. #false} includes: x type].
		[:x |
			x installActiveReplacement: (DCCheckbox new
				fromSource: [:source :repl | repl checked: source contents = 'true']
				toSource: [:source :repl | source contents: (repl checked ifTrue: ['true'] ifFalse: ['false'])])]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkCollapseBlocks [
	<query: #open>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x type = #block].
		[:x | false].
		[:x | x sourceString size > 30000000].
		[:x | x installPassiveReplacement: DCCollapsed new]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkCollapseBlocksOnDoubleClick [
	<query: #doubleClick>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x type = #block].
		[:x | x installPassiveReplacement: DCCollapsed new]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkCreateClassFor: aBlock [

	aBlock sandblockEditor do: (SBStCreateClassCommand new
		name: aBlock contents;
		source: aBlock;
		editor: aBlock sandblockEditor;
		artefact: aBlock containingArtefact)
]

{ #category : #smalltalk }
DCBlock class >> smalltalkCreateNewMethod [
	<query: #shortcut>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x |
			x registerShortcut: #createNewEmptyModule do: [
				{
					[:e | | method |
						method := DCSmalltalkMethod emptyIn: e containingArtefact methodClass.
						e sandblockEditor openMorphInView: method.
						method firstDeepChild startInputAtEnd]}]]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkDeclaration [

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | #(#identifier #'block_argument') includes: x type].
		[:id | {#args. id. id orAllParents: #(#method #block)}].
		[:id :scopes | | decl |
			decl := ((DCQuery
				script: {
					[:scope |
						DCQuery
							firstScript: {
								{
									[:block | "temporaries"
									block childSandblocks detect: [:a | a type = #temporaries] ifNone: [nil]].
									[:args | args childSandblocks detect: [:arg | arg contents = id contents] ifNone: [nil]]}.
								{
									[:block | "block args"
									block childSandblocks select: [:a | a type = #'block_argument']].
									[:args |
										args
											detect: [:arg | (arg contents withoutLeading: #($:)) = (id contents withoutLeading: #($:))]
											ifNone: [nil]]}.
								{
									[:method | "method args"
									method queryAll: '[(keyword_selector (identifier) @) (binary_selector (identifier) @)]'].
									[:args | args detect: [:arg | arg contents = id contents] ifNone: [nil]]}}
							with: scope]}
				first: scopes) ifNil: [
				(Symbol lookup: id contents) ifNotNil: [:sym |
					id containingArtefact methodClass
						bindingOf: sym
						environment: id containingArtefact methodClass environment]]) ifNil: [id containingArtefact ifNotNil: [:m | m methodClass instVarNames detect: [:n | n = id contents] ifNone: [nil]]].
			{#args. id. decl}]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkDeclareBlockLocal: aBlock [

	| block decl |
	decl := DCBlock new
		type: #identifier;
		addMorphBack: (DCText new contents: aBlock contents).
	block := aBlock orAnyParent: {#block. #method}.
	block childSandblocks
		detect: [:b | b type = #temporaries]
		ifFound: [:temporaries |
			aBlock sandblockEditor do: (SBInsertCommand new
				morph: decl;
				container: temporaries;
				index: temporaries submorphCount)]
		ifNone: [ | index |
			index := block children findFirst: [:s | s treeLabel = '|'].
			aBlock sandblockEditor do: (SBInsertCommand new
				morph: (DCBlock new
					type: #temporaries;
					addMorphBack: (DCText new contents: '|');
					addMorphBack: decl;
					addMorphBack: (DCText new contents: '|'));
				index: (index = 0 ifTrue: [2] ifFalse: [index + 1]);
				container: block)]
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkDeclareClassVariable: aBlock [

	aBlock sandblockEditor do: (SBStDeclareClassVarCommand new
		class: aBlock containingArtefact methodClass theNonMetaClass;
		name: aBlock contents;
		source: aBlock)
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkDeclareInstanceVariable: aBlock [

	aBlock sandblockEditor do: (SBStDeclareInstVarCommand new
		class: aBlock containingArtefact methodClass;
		name: aBlock contents;
		source: aBlock)
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkDeclareTemporary: aBlock [

	| block decl |
	decl := DCBlock new
		type: #identifier;
		addMorphBack: (DCText new contents: aBlock contents).
	block := aBlock orAnyParent: {#method}.
	block childSandblocks
		detect: [:b | b type = #temporaries]
		ifFound: [:temporaries |
			aBlock sandblockEditor do: (SBInsertCommand new
				morph: decl;
				container: temporaries;
				index: temporaries submorphCount)]
		ifNone: [ | index |
			index := block children findFirst: [:s | s treeLabel = '|'].
			aBlock sandblockEditor do: (SBInsertCommand new
				morph: (DCBlock new
					type: #temporaries;
					addMorphBack: (DCText new contents: '|');
					addMorphBack: decl;
					addMorphBack: (DCText new contents: '|'));
				index: (index = 0 ifTrue: [2] ifFalse: [index + 1]);
				container: block)]
]

{ #category : #smalltalk }
DCBlock class >> smalltalkFlagMarker [
	<query: #always>

	^ {
		self smalltalkMessageSendSelector.
		[:selector :message | selector = #flag: and: [message children first type = #self and: [message children last type = #symbol]]].
		[:selector :message |
			message
				ensureReplacement: DCFlagMarker
				embed: [:m | {m children last}]
				initDo: [:m :expr | m addMorphBack: expr]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkHighlightIdentifiers [
	<query: #selection>

	^ {
		[:x | x isSelected].
		self smalltalkDeclaration.
		self smalltalkUsesOfDeclaration.
		[:decl :identifiers | identifiers do: #attachHighlight]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkIdentifierAutocompletion [
	<query: #type>

	^ {
		[:x | x isSelected].
		[:x | x type = #identifier].
		[:x |
			x
				addOwnSuggestions: (Smalltalk globals declarations
					collect: [:class | class key]
					into: OrderedCollection new)
				label: 'class'].
		[:id | {#args. id. id orAllParents: #(#method #block)}].
		[:id :scopes |
			scopes do: [:scope |
				DCQuery
					script: {
						[:block | block childSandblocks detect: [:a | a type = #temporaries] ifNone: [nil]].
						[:temps | temps childSandblocks].
						[:vars | id addOwnSuggestions: (vars collect: [:c | c contents]) label: 'temp']}
					with: scope.
				DCQuery
					script: {
						[:block | block childSandblocks select: [:a | a type = #'block_argument']].
						[:vars | id addOwnSuggestions: (vars collect: [:c | c contents]) label: 'block arg']}
					with: scope].
			id].
		[:id |
			DCQuery
				script: {
					self smalltalkMethodSelector.
					[:selector | selector children select: [:c | c type = #identifier]].
					[:args | id addOwnSuggestions: (args collect: [:c | c contents]) label: 'method arg']}
				with: id.
			id].
		[:id | {#args. id. id containingArtefact}].
		[:id :method | id addOwnSuggestions: method methodClass instVarNames label: 'inst var']}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkInsertArg [
	<query: #shortcut>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x |
			#(#First #Second #Third #Fourth #Fifith) withIndexDo: [:name :index |
				x registerShortcut: #use, name, #Argument do: [
					{
						[:block |
							(DCQuery script: {self smalltalkMethodArguments. [:args | (args at: index) contents]} with: block) ifNotNil: [:id |
								(block type = #identifier or: [block sandblockEditor mode = #command])
									ifTrue: [block replaceWith: id, ' ']
									ifFalse: [block insert: id, ' ']]]}]]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkInsertWatch [
	<query: #shortcut>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x |
			x registerShortcut: #wrapWithWatch do: [
				{
					[:expr |
						expr class = DCWatch
							ifTrue: [expr replaceWith: expr expression sourceString]
							ifFalse: [expr wrapWithBefore: '(DCWatch report: (' after: ') for: ', UUID new asString storeString, ')']]}]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkJumpPlaceholder [
	<query: #always>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | #(#identifier #'unary_identifier') includes: x type].
		[:x | x contents = '__sb'].
		[:x | x ensureReplacement: DCJumpPlaceholder initDo: [:b | ]]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkMessageSend [

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | #(keyword_message binary_message unary_message keyword binary_operator unary_identifier) includes: x type].
		[:x | x orParent: #(keyword_message binary_message unary_message)]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkMessageSendAutoCompletion [
	<query: #type>

	^ {
		[:x | x isSelected].
		[:x | "only autocomplete for the first message part (just after receiver)"
		x childIndex = 2].
		[:x | (DCQuery script: self smalltalkMessageSendSelector with: x) ifNotNil: [:res | res, {x}]].
		[:selector :message :part |
			part addSuggestions: ((self sortedSuggestions: Symbol allSymbols for: selector addAll: false max: 10) collect: [:sel |
				DCSuggestionItem new
					selector: sel label: 'send' source: ((sel allSatisfy: #isSpecial) ifTrue: [sel, ' __sb'] ifFalse: [
						(sel includes: $:)
							ifTrue: [
								((sel splitBy: ':') allButLast collectWithIndex: [:p :index |
									p, ((index = 1 and: [part nextBlock ifNotNil: #isExpression ifNil: [false]])
										ifTrue: [':']
										ifFalse: [': __sb'])]) joinSeparatedBy: ' ']
							ifFalse: [sel]]);
					completionAction: [:editor |
						editor selection parent
							allChildrenDetect: [:c | c contents = '__sb']
							ifFound: [:c | c containingSandblock startInputAtStart]
							ifNone: []]])]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkMessageSendSelector [

	^ {
		self smalltalkMessageSend.
		[:message | {#args. message queryAll: '[(keyword) (binary_operator) (unary_identifier)] @part'. message}].
		[:hits :message | {#args. hits select: [:part | part owner = message]. message}].
		[:hits :message | {#args. hits collect: #contents. message}].
		[:parts :message | {#args. parts joinSeparatedBy: ''. message}]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkMethodArguments [

	^ {self smalltalkMethodSelector. [:x | x childSandblocks select: [:c | c type = #identifier]]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkMethodSelector [

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x orAnyParent: #method].
		[:x |
			x childSandblocks
				detect: [:c | #(#'keyword_selector' #'binary_selector' #'unary_selector') includes: c type]
				ifNone: [nil]]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkRunTest [
	<query: #save>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x containingArtefact].
		[:x | (x selector beginsWith: 'test') and: [x methodClass inheritsFrom: TestCase]].
		[:x |
			Project current addDeferredUIMessage: [ | addIcon displayedError |
				x method all: {[:p | p purpose = #testResult]} do: #passiveUninstall.
				addIcon := [:icon | x method addMorphFront: ((SBIcon perform: icon) wrapped: #testResult)].
				displayedError := false.
				
				[(x methodClass selector: x selector) runCase]
					on: TestResult failure
					do: [:signal |
						x messageSendForError: signal argsDo: [:message :args |
							message run: {
								self smalltalkMessageSendSelector.
								[:selector :m | selector = #assert:equals:].
								[:selector :m |
									displayedError := true.
									args do: [:arg |
										DCPreviewValue new
											value: arg value;
											purpose: #testResult;
											installFor: arg key]]}].
						addIcon value: #iconTimesCircle.
						displayedError ifFalse: [signal signal]]
					on: TestResult exError
					do: [:signal |
						addIcon value: #iconTimesCircle.
						signal signal].
				displayedError ifFalse: [addIcon value: #iconCheckCircle]]]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkSelector [

	^ {
		[:x |
			DCQuery
				firstScript: {
					self smalltalkMessageSendSelector.
					{
						[:b | b language = SBTSSmalltalk].
						[:b | b type = #symbol].
						[:sym | {#args. sym lastSubmorph contents. sym}]}.
					{
						[:b | b language = SBTSSmalltalk].
						[:b | b orParent: #(#'keyword_selector' #'binary_selector' #'unary_selector')].
						[:sel |
							{
								#args.
								DCQuery
									script: {
										[:s | s queryAll: '[(keyword) (binary_operator) (unary_identifier)] @part'].
										[:hits | (hits collect: #contents) joinSeparatedBy: '']}
									with: sel.
								sel}]}}
				with: x]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkSelectorWithPlaceholders: aString [

	(aString allSatisfy: #isSpecial) ifTrue: [^ aString, ' __sb'].
	(aString includes: $:) ifFalse: [^ aString].
	^ ((aString splitBy: ':') allButLast collect: [:part | part, ': __sb']) joinSeparatedBy: ' '
]

{ #category : #smalltalk }
DCBlock class >> smalltalkSymbolAutocompletion [
	<query: #type>

	^ {
		[:x | x isSelected].
		[:x | x language = SBTSSmalltalk].
		[:x | x type = #symbol].
		[:x | x addSuggestions: ((self sortedSuggestions: Symbol allSymbols for: x contents allButFirst addAll: false max: 10) collect: [:sel | DCSuggestionItem new selector: sel label: 'symbol' source: '#', sel])]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkToggleBoolean [
	<query: #doubleClick>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | #('true' 'false') includes: x type].
		[:x | x replaceWith: (x type = 'true' ifTrue: ['false'] ifFalse: ['true'])]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkUndeclaredVariable [
	<query: #type>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x type = #identifier].
		[:x |
			(DCQuery script: self smalltalkDeclaration with: x)
				ifNil: [x]
				ifNotNil: [nil]].
		[:x |
			x reportError: (SBErrorDecorator new
				message: 'undeclared variable';
				fixActions: (x contents first isUppercase
					ifTrue: [
						{
							SBCodeAction
								labeled: 'Declare class var'
								for: x
								do: [:block | self smalltalkDeclareClassVariable: block].
							SBCodeAction
								labeled: 'Create class ', x contents
								for: x
								do: [:block | self smalltalkCreateClassFor: block]}]
					ifFalse: [
						{
							SBCodeAction
								labeled: 'Declare block-local'
								for: x
								do: [:block | self smalltalkDeclareBlockLocal: block].
							SBCodeAction
								labeled: 'Declare method temporary'
								for: x
								do: [:block | self smalltalkDeclareTemporary block].
							SBCodeAction
								labeled: 'Declare instance variable'
								for: x
								do: [:block | self smalltalkDeclareInstanceVariable: block]}]))]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkUnknownSelector [
	<query: #type>

	^ {
		self smalltalkMessageSendSelector.
		[:selector :message | (Symbol lookup: selector) isNil].
		[:selector :message |
			(message queryChildrenFirst: '[(unary_identifier) (binary_operator) (keyword)] @') reportError: (SBErrorDecorator new
				message: 'unknown message';
				fixActions: {
					SBCodeAction labeled: 'Create method on ...' for: message do: [:node | | method class |
						class := UIManager default chooseClassOrTrait.
						class ifNotNil: [
							method := DCSmalltalkMethod
								newWith: (self smalltalkSelectorWithPlaceholders: selector)
								in: class.
							node sandblockEditor do: (SBEditorOpenMorphCommand new
								morph: method;
								editor: node sandblockEditor;
								isUnsaved: true;
								yourself)]].
					SBCodeAction labeled: 'Confirm selector' for: message do: [:node | node selector asSymbol]})]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkUnusedVariable [
	<query: #(#always)>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x hasParent: #temporaries].
		[:x | {#args. x. x}].
		self smalltalkUsesOfDeclaration.
		[:decl :uses | uses size = 1].
		[:decl :uses |
			decl reportError: (SBErrorDecorator new
				message: 'unused variable';
				fixActions: {SBCodeAction labeled: 'Remove unused declaration' for: decl do: [:node | node deleteBlock]})]}
]

{ #category : #'smalltalk - helpers' }
DCBlock class >> smalltalkUsesOfDeclaration [

	^ {
		[:id :decl |
			decl isSandblock
				ifTrue: [{#args. decl. decl orAnyParent: #(#block #method)}]
				ifFalse: [{#args. decl. id containingArtefact}]].
		[:decl :scope | | search |
			search := decl isSandblock
				ifTrue: [decl contents withoutLeading: #($:)]
				ifFalse: [decl isString ifTrue: [decl] ifFalse: [decl name]].
			{
				#args.
				decl.
				scope allChildrenSelect: [:x | (#(#identifier #'block_argument') includes: x type) and: [(x contents withoutLeading: #($:)) = search]]}]}
]

{ #category : #smalltalk }
DCBlock class >> smalltalkWatch [
	<query: #always>

	^ {
		[:x | x language = SBTSSmalltalk].
		[:x | x type = #'keyword_message'].
		[:x | true].
		self smalltalkMessageSendSelector.
		[:selector :message | selector = #report:for:].
		[:selector :message |
			(message parent type = 'parenthesized_expression'
				ifTrue: [message parent]
				ifFalse: [message])
				ensureReplacement: DCWatch
				embed: [:w | | expr |
					expr := message childNodes third.
					{
						expr type = 'parenthesized_expression'
							ifTrue: [expr childNodes second]
							ifFalse: [expr]}]
				initDo: [:w :expr | w addMorphBack: expr]]}
]

{ #category : #'text modify' }
DCBlock class >> swap: aRange with: anotherRange in: aString do: aBlock [

	| first second new |
	self
		example: [DCBlock new]
		args: [
			{
				SBTSRange
					start: (SBTSPosition line: 0 character: 8 index: 8)
					end: (SBTSPosition line: 0 character: 9 index: 9).
				SBTSRange
					start: (SBTSPosition line: 0 character: 2 index: 2)
					end: (SBTSPosition line: 0 character: 5 index: 5).
				'1234567890'}]
		label: 'example'.
	first := aRange start index < anotherRange start index
		ifTrue: [aRange]
		ifFalse: [anotherRange].
	second := aRange start index < anotherRange start index
		ifTrue: [anotherRange]
		ifFalse: [aRange].
	new := (aString first: first start index), (aString copyFrom: second start index + 1 to: second end index), (aString copyFrom: first end index + 1 to: second start index), (aString copyFrom: first start index + 1 to: first end index), (aString allButFirst: second end index).
	
	^ aBlock
		value: new
		value: (SBTSInputEdit new
			startByte: first start index;
			oldEndByte: second end index;
			newEndByte: second end index;
			bytesToPointsIn: aString new: new)
		value: [:source :block |
			self
				swap: (first withSize: second size)
				with: (second withSize: first size) + (second size - first size)
				in: source
				do: block]
]

{ #category : #'text modify' }
DCBlock class >> wrap: aRange in: aString open: anotherString close: aThirdString [

	self
		example: [DCBlock new]
		args: [{SBTSRange start: 3 size: 3. 'abcdefghi'. '('. ')'}]
		label: 'example'.
	
	^ (aString first: aRange start index), anotherString, (aString copyFrom: aRange start index + 1 to: aRange end index), aThirdString, (aString allButFirst: aRange end index)
]

{ #category : #'as yet unclassified' }
DCBlock >> absolutePositionOf: aMorph [

	| n |
	n := 0.
	self allChildrenDo: [:m |
		n := n + 1.
		m = aMorph ifTrue: [^ n]].
	^ self assert: false
]

{ #category : #'as yet unclassified' }
DCBlock >> adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent [
	"do not place closing pair characters if they are coming up right after"

	(self pairMap keyAtValue: input ifAbsent: nil) ifNotNil: [:openChar |
		(source at: cursorIndex + 1 ifPresent: [:char | input first = char] ifAbsent: [false]) ifTrue: [
			self owner startInputAtSourceIndex: cursorIndex + 1.
			^ '']].
	
	self pairMap at: input ifPresent: [:complete |
		"do not autocomplete quotes in words"
		(complete = '''' and: [source at: cursorIndex ifPresent: #isAlphaNumeric ifAbsent: [false]]) ifTrue: [^ input].
		
		"do not autocomplete after backslash"
		textMorph characterBeforeCursor = $\ ifTrue: [^ input].
		
		^ input, complete].
	
	^ input
]

{ #category : #'query actions' }
DCBlock >> addOwnSuggestions: aCollection label: aString [

	self addSuggestions: ((self class sortedSuggestions: aCollection for: self contents addAll: false max: 10) collect: [:sel | DCSuggestionItem new selector: sel label: aString source: sel])
]

{ #category : #'query actions' }
DCBlock >> addSuggestions: aCollection [

	self queryState addSuggestions: aCollection for: self
]

{ #category : #'as yet unclassified' }
DCBlock >> alias [

	^ nil
]

{ #category : #queries }
DCBlock >> all: aCollection do: aBlock [

	(self allBlocksSelect: [:b | (DCQuery script: aCollection with: b) notNil]) do: aBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> allChildrenDetect: aBlock ifFound: aSuccessBlock ifNone: aFailBlock [

	self allChildrenDo: [:block | (aBlock value: block) ifTrue: [^ aSuccessBlock value: block]].
	^ aFailBlock value
]

{ #category : #hierarchy }
DCBlock >> allDomainBlocksWithDepthDo: aBlock leafDo: anotherBlock depth: aNumber [

	self submorphs do: [:m | m allDomainBlocksWithDepthDo: aBlock leafDo: anotherBlock depth: aNumber + 1].
	aBlock value: self value: aNumber
]

{ #category : #hierarchy }
DCBlock >> allParents [

	^ self allParentsUpTo: self rootBlock
]

{ #category : #hierarchy }
DCBlock >> allParentsUpTo: aBlock [

	| current parents |
	self = aBlock ifTrue: [^ #()].
	
	current := self parent.
	parents := OrderedCollection new.
	
	[
		parents add: current.
		current = aBlock ifTrue: [^ parents].
		current := current parent] repeat
]

{ #category : #'as yet unclassified' }
DCBlock >> allTextMorphsDo: aBlock [
	"iterate over morphs, not children, as we're looking for visible text morphs"

	self allMorphsDo: [:m | m isTextMorph ifTrue: [aBlock value: m]]
]

{ #category : #'as yet unclassified' }
DCBlock >> applyBlock [

	^ [:new :edit :undo | self applyEdit: edit source: new cursorAt: edit newEndByte undoDo: undo]
]

{ #category : #'as yet unclassified' }
DCBlock >> applyBlockWithCursor: aNumber [

	^ [:new :edit :undo | self applyEdit: edit source: new cursorAt: aNumber undoDo: undo]
]

{ #category : #'as yet unclassified' }
DCBlock >> applyEdit: edit source: newSource cursorAt: newIndex undoDo: aBlock [

	| oldTree apply |
	oldTree := self rootBlock.
	
	apply := [ | newTree |
		newTree := DCBlock parse: newSource old: oldTree language: oldTree language.
		DCMatcher new performEditsIn: newTree to: oldTree.
		oldTree
			privateTSTree: newTree privateTSTree;
			privateSource: newTree privateSource].
	
	aBlock
		ifNotNil: [
			self sandblockEditor do: (SBDoItCommand new
				do: apply;
				undo: [
					oldTree tryApplyChange: [:source |
						aBlock
							value: source
							value: [:new :undoEdit :undo | oldTree applyEdit: undoEdit source: new cursorAt: undoEdit newEndByte undoDo: nil]]])]
		ifNil: [apply value].
	
	oldTree placeCursorIn: oldTree at: newIndex
]

{ #category : #'as yet unclassified' }
DCBlock >> artefactChanged: aMethodBlock [

	(self containingArtefact = aMethodBlock and: [self isRootBlock]) ifTrue: [self queryState updateChangeQueries]
]

{ #category : #'as yet unclassified' }
DCBlock >> artefactSaved: aMethodBlock [

	(self containingArtefact = aMethodBlock and: [self isRootBlock]) ifTrue: [self queryState updateQueriesFor: #save at: self]
]

{ #category : #'query actions' }
DCBlock >> assertConsecutiveRanges [

	| current |
	current := 0.
	self allMorphsDo: [:m |
		m class = DCText ifTrue: [
			self assert: m range start index = current.
			current := m range end index].
		m class = DCLineBreak ifTrue: [
			self assert: m range start index = current.
			current := m range end index]]
]

{ #category : #'query actions' }
DCBlock >> attachHighlight [

	self queryState highlight: self
]

{ #category : #'as yet unclassified' }
DCBlock >> blockFor: aRange [

	self allChildrenDo: [:block | (block isTSMorph and: [block range = aRange]) ifTrue: [^ block]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> borderVertices [

	| level endLevel |
	level := 0.
	self firstDeepSubmorph firstOwnerSuchThat: [:o |
		level := level + 1.
		o = self].
	level := level * self layoutInset.
	endLevel := 0.
	self lastDeepSubmorph firstOwnerSuchThat: [:o |
		endLevel := endLevel + 1.
		o = self].
	endLevel := endLevel * self layoutInset.
	
	^ {
		self bounds bottomLeft.
		self left @ (self firstDeepSubmorph bottom + level).
		self firstDeepSubmorph left - level @ (self firstDeepSubmorph bottom + level).
		self firstDeepSubmorph left - level @ self top.
		self bounds topRight.
		self right @ (self lastDeepSubmorph top - endLevel).
		self lastDeepSubmorph right + endLevel @ (self lastDeepSubmorph top - endLevel).
		self lastDeepSubmorph right + endLevel @ self bottom}
]

{ #category : #'as yet unclassified' }
DCBlock >> childNodes [

	^ self children reject: [:c | c isExtra]
]

{ #category : #'as yet unclassified' }
DCBlock >> children [

	^ Array streamContents: [:s | super children do: [:c | c isReplacement ifTrue: [c resolveSource ifNotNil: [:child | s nextPut: child]] ifFalse: [s nextPut: c]]]
]

{ #category : #'as yet unclassified' }
DCBlock >> clearCache [

	super clearCache.
	self removeProperty: #treeHash
]

{ #category : #'as yet unclassified' }
DCBlock >> clearInput [
	<action>

	self tryApplyChange: [:source :textMorph | self class replace: self activeTextMorph range in: source with: '' do: self applyBlock]
]

{ #category : #'as yet unclassified' }
DCBlock >> compatibleWithType: aSymbol [

	^ self type = aSymbol
]

{ #category : #'as yet unclassified' }
DCBlock >> containingArtefact [

	^ self isArtefact
		ifTrue: [self]
		ifFalse: [self parent ifNotNil: [:b | b containingArtefact]]
]

{ #category : #'as yet unclassified' }
DCBlock >> contentsToDisplay [

	^ self contents
]

{ #category : #'as yet unclassified' }
DCBlock >> copyRangesFrom: newTree to: oldTree [

	oldTree range: newTree range.
	newTree children with: oldTree children do: [:a :b | self copyRangesFrom: a to: b]
]

{ #category : #'as yet unclassified' }
DCBlock >> currentTextMorph [

	self submorphsDo: [:m | m isTextMorph ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteAfterCursor [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex | self class deleteFrom: source at: cursorIndex + 1 do: self applyBlock].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteBeforeCursor [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex | self class deleteFrom: source at: cursorIndex do: self applyBlock].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteBlock [
	<action>

	self isArtefact ifTrue: [^ super deleteBlock].
	
	self tryApplyChange: [:source :textMorph :cursorIndex | | delRange |
		delRange := textMorph range.
		self trailingTerminator ifNotNil: [:t |
			delRange := SBTSRange merging: {delRange. t range}.
			(source atPin: delRange end index + 1) = Character cr ifTrue: [delRange := SBTSRange start: delRange start end: delRange end + 1]].
		self class replace: delRange in: source with: '' do: self applyBlock]
]

{ #category : #'as yet unclassified' }
DCBlock >> deleteBlockWithCopy [
	<action>

	self sandblockEditor copyBuffer: self preferQuick: true.
	self deleteBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> diff: oldTree to: newTree [

	
]

{ #category : #'as yet unclassified' }
DCBlock >> doLayoutIn: layoutBounds [

	| info |
	self hasSubmorphs ifFalse: [^ fullBounds := self outerBounds].
	
	info := DCLayoutInfo new
		origin: layoutBounds origin;
		lineStart: layoutBounds left;
		padding: self layoutInset.
	
	self layoutWith: info.
	self setBoundsDirect: (info bounds extendBy: info padding).
	
	self assert: fullBounds notNil
]

{ #category : #'as yet unclassified' }
DCBlock >> doubleClick: anEvent [

	self queryState updateQueriesFor: #doubleClick at: self
]

{ #category : #'as yet unclassified' }
DCBlock >> drawBackgroundOn: aCanvas [

	| policy |
	policy := self colorPolicy.
	self allMorphsDo: [:c |
		c class = DCLineBreak ifTrue: [ | level |
			level := 0.
			c firstOwnerSuchThat: [:o |
				level := level + 1.
				o = self].
			aCanvas
				drawPolygon: self borderVertices
				color: self drawnColor
				borderWidth: (policy borderWidthForBlock: self)
				borderColor: (policy borderColorForBlock: self).
			^ self]].
	
	^ aCanvas
		frameAndFillRoundRect: self bounds
		radius: policy cornerRadius
		fillStyle: self drawnColor
		borderWidth: (policy borderWidthForBlock: self)
		borderColor: (policy borderColorForBlock: self)
]

{ #category : #'as yet unclassified' }
DCBlock >> drawnColor [

	^ self prefersNoBorder
		ifTrue: [super drawnColor alpha: 0]
		ifFalse: [super drawnColor]
]

{ #category : #'as yet unclassified' }
DCBlock >> emphasis [

	self highlight ifNotNil: [:h |
		(h beginsWith: 'major_declaration') ifTrue: [^ TextEmphasis bold].
		self type = #comment ifTrue: [^ TextEmphasis italic]].
	^ self colorPolicy defaultEmphasis
]

{ #category : #'as yet unclassified' }
DCBlock >> encompasses: aRange [

	^ self range encompasses: aRange
]

{ #category : #'query actions' }
DCBlock >> ensureReplacement: aClass embed: aCollection initDo: aBlock [

	self queryState ensureReplacement: aClass for: self embed: aCollection initDo: aBlock
]

{ #category : #'query actions' }
DCBlock >> ensureReplacement: aClass initDo: aBlock [

	self queryState ensureReplacement: aClass for: self embed: [:m | {}] initDo: aBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> field [

	^ field
]

{ #category : #'as yet unclassified' }
DCBlock >> field: aString [

	field := aString
]

{ #category : #'as yet unclassified' }
DCBlock >> firstSourceCharacter [

	self writeSourceOn: (SBImmediateStream with: [:c | ^ c]) indent: 0 forCompare: false.
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> fixedNumberOfChildren [

	^ false
]

{ #category : #'as yet unclassified' }
DCBlock >> getSourceStringAndMark [

	| stream |
	stream := SBLineInfoStream on: ''.
	self writeSourceOn: stream indent: 0 forCompare: false.
	^ stream contents
]

{ #category : #'as yet unclassified' }
DCBlock >> grammarHandler [

	^ DCGrammarHandler new
]

{ #category : #'as yet unclassified' }
DCBlock >> handleInsertEvent: anEvent in: textMorph [

	| pairMap input |
	pairMap := self pairMap.
	input := anEvent keyCharacter asString.
	pairMap at: input ifPresent: [:complete |
		"do not autocomplete quotes in words"
		((textMorph characterBeforeCursor
			ifNotNil: #isAlphaNumeric
			ifNil: [false]) and: [complete = '''']) ifTrue: [^ textMorph insertString: input].
		
		"do not autocomplete after backslash"
		textMorph characterBeforeCursor = $\ ifTrue: [^ textMorph insertString: input].
		
		^ textMorph
			insertString: input, complete;
			moveCursor: -1].
	
	SBToggledCode comment: '' active: 0 do: {
		[
			(pairMap keyAtValue: input ifAbsent: [nil]) ifNotNil: [:key |
				"jump to a matching closing bracket just after us"
				(textMorph nextMorphThat: #isTextMorph) ifNotNil: [:m |
					m contents = input ifTrue: [
						^ self sandblockEditor
							startInput: m containingSandblock
							at: 900000000
							replacingContents: false
							in: m]].
				
				"skip inserting closing parens that already exist"
				(textMorph contents notEmpty and: [textMorph contents includesSubstring: input]) ifTrue: [^ self]]]}.
	
	^ super keyStroke: anEvent
]

{ #category : #hierarchy }
DCBlock >> hasAnyParent: aBlock [

	self isRootBlock ifTrue: [^ false].
	
	self parent = aBlock ifTrue: [^ true].
	
	^ self parent hasAnyParent: aBlock
]

{ #category : #hierarchy }
DCBlock >> hasParent: aCollectionOrSymbol [

	| matches |
	self isRootBlock ifTrue: [^ false].
	
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	^ matches includes: self parent type
]

{ #category : #'as yet unclassified' }
DCBlock >> highlight [

	^ highlight ifNil: [self updateAllHighlights]
]

{ #category : #'as yet unclassified' }
DCBlock >> highlight: aString [

	highlight := aString
]

{ #category : #'as yet unclassified' }
DCBlock >> indentFor: aBlock current: aNumber [

	^ (self language indentMatch: aBlock)
		ifTrue: [aNumber + 1]
		ifFalse: [aNumber]
]

{ #category : #'as yet unclassified' }
DCBlock >> initialize [

	super initialize.
	
	range := SBTSRange null.
	
	self
		layoutPolicy: DCLayout new;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
DCBlock >> inputClosestTextMorphTo: cursorPosition [

	| best bestDistance atStart |
	best := nil.
	bestDistance := Float infinity.
	atStart := false.
	
	"match on same line"
	self allChildrenDo: [:t |
		t isTextMorph ifTrue: [
			t range start line = cursorPosition line ifTrue: [ | distance |
				distance := (t range start character - cursorPosition character) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := true.
					best := t]].
			t range end line = cursorPosition line ifTrue: [ | distance |
				distance := (t range end character - cursorPosition character) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := false.
					best := t]]]].
	
	"match on different line"
	best ifNil: [
		self allChildrenDo: [:t |
			t isTextMorph ifTrue: [ | distance |
				distance := (t range start line - cursorPosition line) abs min: (t range end line - cursorPosition line) abs.
				distance < bestDistance ifTrue: [
					bestDistance := distance.
					atStart := false.
					best := t]]]].
	
	best ifNotNil: [
		self sandblockEditor
			startInput: best containingSandblock
			at: (atStart ifTrue: [1] ifFalse: [900000000])
			replacingContents: false
			in: best]
]

{ #category : #'as yet unclassified' }
DCBlock >> insert: aString [

	self tryApplyChange: [:source :textMorph :cursorIndex | self class insert: aString in: source at: cursorIndex + 1 do: self applyBlock].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
DCBlock >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> insertStatementAboveOrBelow: anAboveBoolean [

	(self orOwnerSuchThat: [:morph | morph isTSBlock and: [morph isStatement]]) ifNotNil: [:statement | | target insertSeparatorAfter indent point index |
		target := (anAboveBoolean not and: [(statement submorphAfter ifNotNil: #treeLabel) = self language statementTerminator])
			ifTrue: [
				insertSeparatorAfter := true.
				statement submorphAfter]
			ifFalse: [
				"if we do not have a trailing dot, we need to insert the dot before the element"
				insertSeparatorAfter := anAboveBoolean.
				statement].
		
		indent := ''.
		[ | cur |
			cur := target morphBeforeOrAfter: anAboveBoolean.
			[cur notNil and: [cur isExtra and: [anAboveBoolean not or: [cur class ~= DCLineBreak]]]] whileTrue: [
				indent := indent, (cur treeLabel select: [:c | c = Character space or: [c = Character tab]]).
				cur := cur morphBeforeOrAfter: anAboveBoolean]] value.
		
		point := anAboveBoolean ifTrue: [target range start] ifFalse: [target range end].
		index := point index.
		self tryApplyChange: [:source |
			self class
				insert: String cr, indent
				in: source
				at: index + 1
				do: (self applyBlockWithCursor: index + (anAboveBoolean ifTrue: [-1] ifFalse: [2]) + indent size).
			self sandblockEditor do: (SBRelInsertCommand new
				near: (target owner submorphs detect: [:m |
					anAboveBoolean
						ifTrue: [m range start index = index]
						ifFalse: [m range end index = (index + (1 + indent size))]])
				before: anAboveBoolean
				in: statement owner
				morph: (DCEmptyStatement new
					language: self language;
					range: (SBTSRange point: (anAboveBoolean ifTrue: [point] ifFalse: [point + 1 + indent size]));
					insertSeparatorAfter: insertSeparatorAfter;
					contents: ''))]]
]

{ #category : #'as yet unclassified' }
DCBlock >> insertStatementHasCandidate [

	^ true
]

{ #category : #'as yet unclassified' }
DCBlock >> installActiveReplacement: aBlock [

	self sandblockEditor do: (SBCombinedCommand newWith: {
		SBReplaceCommand new target: self replacer: (aBlock source: self).
		SBMutatePropertyCommand new
			target: self;
			selector: #replacedParent;
			value: aBlock})
]

{ #category : #'as yet unclassified' }
DCBlock >> installActiveReplacement: aBlock do: aClosure [

	self sandblockEditor do: (SBCombinedCommand newWith: {
		SBReplaceCommand new target: self replacer: (aBlock source: self).
		SBMutatePropertyCommand new
			target: self;
			selector: #replacedParent;
			value: aBlock}).
	aClosure value: aBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> installPassiveReplacement: aBlock [

	aBlock source: self.
	self replaceBy: aBlock.
	self replacedParent: aBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> installPassiveReplacement: aBlock do: aClosure [

	aBlock source: self.
	self replaceBy: aBlock.
	self replacedParent: aBlock.
	aClosure value: aBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> intoWorld: aWorld [

	super intoWorld: aWorld.
	
	self isRootBlock ifTrue: [
		self sandblockEditor
			when: #selectionChanged
			send: #updateSelectionQueries
			to: self queryState.
		self sandblockEditor
			when: #batchedChange
			send: #updateTypeQueries
			to: self queryState.
		self queryState
			updateQueriesFor: #open;
			updateQueriesFor: #always]
]

{ #category : #'as yet unclassified' }
DCBlock >> isArtefact [

	^ self floating and: [self isRootBlock]
]

{ #category : #'as yet unclassified' }
DCBlock >> isBlockBody [

	^ self language ifNotNil: [:l | l blockBodyTypes includes: self type] ifNil: [false]
]

{ #category : #'as yet unclassified' }
DCBlock >> isExpression [

	(self type = #ERROR and: [self submorphCount = 1]) ifTrue: [^ self firstSubmorph isExpression].
	
	^ self language expressionTypes anySatisfy: [:type | self language instance grammar is: self type subtypeOf: type]
]

{ #category : #testing }
DCBlock >> isExtra [

	^ false
]

{ #category : #hierarchy }
DCBlock >> isOrHasParent: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	^ (matches includes: self type) or: [matches includes: self parent type]
]

{ #category : #'as yet unclassified' }
DCBlock >> isPart [

	^ self highlight notNil and: [self highlight endsWith: '.part']
]

{ #category : #'as yet unclassified' }
DCBlock >> isReplacement [

	^ false
]

{ #category : #'as yet unclassified' }
DCBlock >> isRootBlock [

	^ self type = (self language ifNotNil: #rootRuleName)
]

{ #category : #'as yet unclassified' }
DCBlock >> isTSBlock [

	^ true
]

{ #category : #'as yet unclassified' }
DCBlock >> isTSMorph [

	^ true
]

{ #category : #'as yet unclassified' }
DCBlock >> keyStroke: anEvent [

	self tryApplyChange: [:source :textMorph :cursorIndex | | input |
		input := anEvent keyCharacter asString.
		(input first isPrintable and: [anEvent commandKeyPressed not]) ifTrue: [
			(self adaptInput: input in: source at: cursorIndex textMorph: textMorph event: anEvent) ifNotEmpty: [:text |
				self class
					insert: text
					in: source
					at: cursorIndex + 1
					do: (self applyBlockWithCursor: cursorIndex + (text indexOf: anEvent keyCharacter))]]].
	self batchedChangeStep
]

{ #category : #'as yet unclassified' }
DCBlock >> language [

	^ language ifNil: [self owner ifNotNil: #language]
]

{ #category : #'as yet unclassified' }
DCBlock >> language: aLanguage [

	language := aLanguage
]

{ #category : #'as yet unclassified' }
DCBlock >> layoutCommands [

	self hasSubmorphs ifFalse: [^ SBAlgebraCommand morph data: self].
	^ SBAlgebraCommand container
		morph: self;
		data: (Array streamContents: [:stream |
			self submorphs overlappingPairsDo: [:a :b |
				stream nextPut: a layoutCommands.
				b class = DCLineBreak ifTrue: [stream nextPut: (SBAlgebraCommand hardLine withGap: true)]].
			self submorphs ifNotEmpty: [stream nextPut: self lastSubmorph layoutCommands]])
]

{ #category : #'as yet unclassified' }
DCBlock >> layoutInset [

	SBToggledCode comment: '' active: 1 do: {[true ifTrue: [^ 0]]}.
	
	self isBlockBody ifTrue: [^ 4 @ 3].
	
	^ (self type = 'ERROR' and: [self childSandblocks notEmpty])
		ifTrue: [0]
		ifFalse: [2 @ (self submorphCount > 3 ifTrue: [2] ifFalse: [0])]
]

{ #category : #'as yet unclassified' }
DCBlock >> layoutWith: info [

	info depth: info depth + 1.
	info x: info x + (info padding asPoint) x.
	info y: info y + (info padding asPoint) y.
	self submorphs do: [:morph | info place: morph].
	info y: info y - (info padding asPoint) y.
	info x: info x + (info padding asPoint) x.
	info depth: info depth - 1
]

{ #category : #'as yet unclassified' }
DCBlock >> minBoundsWith: info [

	self submorphs do: [:morph | info measure: morph].
	^ info bounds
]

{ #category : #'as yet unclassified' }
DCBlock >> noteNewOwner: aMorph [

	super noteNewOwner: aMorph.
	
	"check if we have just been moved out of a replacement"
	(self replacedParent notNil and: [aMorph notNil and: [aMorph class = DCBlock]]) ifTrue: ["self replacedParent: nil"
	]
]

{ #category : #hierarchy }
DCBlock >> orAllParents: aCollectionOrSymbol [

	| matches current res |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	
	current := self.
	res := OrderedCollection new.
	[
		(matches includes: current type) ifTrue: [res add: current].
		current isRootBlock ifTrue: [^ res].
		current := current parent] repeat
]

{ #category : #hierarchy }
DCBlock >> orAnyParent: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isString
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	(matches includes: self type) ifTrue: [^ self].
	self isRootBlock ifTrue: [^ nil].
	self parent isTSMorph ifFalse: [^ nil].
	^ self parent orAnyParent: aCollectionOrSymbol
]

{ #category : #hierarchy }
DCBlock >> orParent: aCollectionOrSymbol [

	| matches |
	matches := aCollectionOrSymbol isSymbol
		ifTrue: [{aCollectionOrSymbol}]
		ifFalse: [aCollectionOrSymbol].
	(matches includes: self type) ifTrue: [^ self].
	self isRootBlock ifTrue: [^ nil].
	(matches includes: self parent type) ifTrue: [^ self parent].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	self isRootBlock ifTrue: [
		self sandblockEditor
			removeActionsWithReceiver: self queryState forEvent: #selectionChanged;
			removeActionsWithReceiver: self queryState forEvent: #batchedChange]
]

{ #category : #'as yet unclassified' }
DCBlock >> ownerWithForegroundColor [

	^ self highlight = #'_sb_none'
		ifTrue: [self owner ifNotNil: [:o | o ownerWithForegroundColor]]
		ifFalse: [self]
]

{ #category : #'as yet unclassified' }
DCBlock >> pairMap [

	^ Dictionary newFrom: {'(' -> ')'. '''' -> ''''. '"' -> '"'. '`' -> '`'. '{' -> '}'. '[' -> ']'}
]

{ #category : #hierarchy }
DCBlock >> parent [

	^ self replacedParent ifNotNil: [:p | p isReplacement ifTrue: [p owner] ifFalse: [p]] ifNil: [self parentSandblock]
]

{ #category : #'as yet unclassified' }
DCBlock >> parentNode [

	^ self parentSandblock ifNotNil: [:p | p isTSBlock ifTrue: [p] ifFalse: [nil]]
]

{ #category : #'actions smalltalk' }
DCBlock >> pasteReplace [
	<action>

	self tryApplyChange: [:source :textMorph :cursorIndex | | str |
		str := Clipboard clipboardText string.
		
		cursorIndex class = SBTSRange
			ifTrue: [self class replace: cursorIndex in: source with: str do: self applyBlock]
			ifFalse: [self class insert: str in: source at: cursorIndex + 1 do: self applyBlock]]
]

{ #category : #'as yet unclassified' }
DCBlock >> performAction: aSymbol [

	
	(self queryState performShortcut: aSymbol for: self) ifTrue: [^ true].
	
	(super performAction: aSymbol) ifTrue: [^ true].
	
	^ false
]

{ #category : #'as yet unclassified' }
DCBlock >> placeCursorIn: newTree at: newIndex [

	newIndex ifNil: [^ self].
	
	^ newIndex isNumber ifTrue: [newTree startInputAtSourceIndex: newIndex] ifFalse: [ | target |
		target := (newTree blockFor: newIndex) ifNil: [^ self].
		target isTextMorph
			ifTrue: [
				newTree sandblockEditor
					startInput: target containingSandblock
					at: 1
					replacingContents: false
					in: target]
			ifFalse: [newTree sandblockEditor selectNoInput: target]]
]

{ #category : #'as yet unclassified' }
DCBlock >> preferredColorIn: aColorPolicy [

	^ self slot preferredColorIn: aColorPolicy for: self highlight
]

{ #category : #'as yet unclassified' }
DCBlock >> prefersNoBorder [

	^ self isPart
]

{ #category : #'as yet unclassified' }
DCBlock >> prettyPrint [

	self tryApplyChange: [:source | | new |
		new := [
			PPFormatter
				formatString: source
				class: (self containingArtefact ifNotNil: #relatedClass ifNil: [nil class])
				noPattern: false]
			on: SyntaxErrorNotification
			do: [source].
		self
			applyEdit: nil
			source: new
			cursorAt: 1
			undoDo: [:undoSource :block | block value: source value: nil value: nil]]
]

{ #category : #'as yet unclassified' }
DCBlock >> prettySourceString [

	self allBlocksDo: [:b | b valid ifFalse: [^ self sourceString]].
	^ self language runtime
		ifNotNil: [:r | r prettyPrint: self sourceString]
		ifNil: [self sourceString]
]

{ #category : #'as yet unclassified' }
DCBlock >> printOn: aStream [

	aStream nextPutAll: self type
]

{ #category : #'as yet unclassified' }
DCBlock >> printTree [

	| s |
	s := '' writeStream.
	self printTreeOn: s indent: 0.
	^ s contents
]

{ #category : #'as yet unclassified' }
DCBlock >> printTreeOn: aStream indent: aNumber [

	aNumber timesRepeat: [aStream tab].
	aStream nextPutAll: '('.
	aStream nextPutAll: self type.
	aStream cr.
	self children do: [:c | c printTreeOn: aStream indent: aNumber + 1] separatedBy: [aStream cr].
	aStream nextPutAll: ')'
]

{ #category : #accessing }
DCBlock >> privateSource [

	^ self valueOfProperty: #tsSource
]

{ #category : #accessing }
DCBlock >> privateSource: aString [

	self setProperty: #tsSource toValue: aString
]

{ #category : #accessing }
DCBlock >> privateTSTree [

	^ self valueOfProperty: #tsTree
]

{ #category : #accessing }
DCBlock >> privateTSTree: aTree [

	self setProperty: #tsTree toValue: aTree
]

{ #category : #accessing }
DCBlock >> privateTSTreeOrNilDo: aBlock [

	^ (self valueOfProperty: #tsTree) ifNotNil: [:tree | tree isNull ifFalse: [aBlock value: tree] ifTrue: [nil]]
]

{ #category : #'as yet unclassified' }
DCBlock >> queryAll: aString [

	self assert: (aString includes: $@) description: 'query needs a capture (@) to be useful'.
	
	^ Array streamContents: [:stream |
		self allChildrenDo: [:block |
			block isTSMorph ifTrue: [
				(SBTSQuery new
					prepare: aString;
					executeCaptureAgainst: block) do: [:assoc | stream nextPut: assoc value]]]]
]

{ #category : #'as yet unclassified' }
DCBlock >> queryChildrenFirst: aString [

	self assert: (aString includes: $@) description: 'query needs a capture (@) to be useful'.
	
	self children do: [:block |
		block isTSMorph ifTrue: [
			(SBTSQuery new
				prepare: aString;
				executeCaptureAgainst: block) do: [:assoc | ^ assoc value]]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> queryFirst: aString [

	self assert: (aString includes: $@) description: 'query needs a capture (@) to be useful'.
	
	self allChildrenDo: [:block |
		block isTSMorph ifTrue: [
			(SBTSQuery new
				prepare: aString;
				executeCaptureAgainst: block) do: [:assoc | ^ assoc value]]].
	^ nil
]

{ #category : #accessing }
DCBlock >> queryState [

	^ self rootBlock
		valueOfProperty: #queryState
		ifAbsentPut: [DCQueryState new rootBlock: self]
]

{ #category : #'as yet unclassified' }
DCBlock >> range [

	^ range
]

{ #category : #'as yet unclassified' }
DCBlock >> range: aRange [

	range := aRange
]

{ #category : #'query actions' }
DCBlock >> registerShortcut: aSymbol do: aBlock [

	" a previous shortcut may have removed us from the world, abort "
	self isInWorld ifFalse: [^ self].
	
	self queryState tryShortcut: aSymbol do: aBlock
]

{ #category : #'as yet unclassified' }
DCBlock >> reloadArtefact [
	<action>

	| method |
	method := (DCSmalltalkMethod for: self containingArtefact object)
		hResizing: self containingArtefact hResizing;
		width: self containingArtefact width;
		yourself.
	
	self sandblockEditor do: (SBReplaceCommand new target: self containingArtefact replacer: method).
	
	method firstDeepChild startInputAtEnd
]

{ #category : #'as yet unclassified' }
DCBlock >> replace: oldTree with: newTree [

	^ SBToggledCode comment: '' active: 1 do: {
		[ | editor |
			editor := self sandblockEditor.
			DCMatcher new doCommandForEditsIn: newTree to: oldTree in: editor.
			self sandblockEditor do: (SBCombinedCommand newWith: {
				SBMutatePropertyCommand new
					target: oldTree;
					selector: #privateSource;
					value: newTree privateSource}).
			oldTree].
		[
			self sandblockEditor do: (SBReplaceCommand new
				target: oldTree replacer: newTree;
				shouldMergeWithNext: true).
			newTree
				position: oldTree position;
				width: oldTree width;
				yourself]}
]

{ #category : #'as yet unclassified' }
DCBlock >> replaceWith: aString [

	self tryApplyChange: [:source :textMorph :cursorIndex | self class replace: textMorph range in: source with: aString do: self applyBlock]
]

{ #category : #accessing }
DCBlock >> replacedParent [

	^ self valueOfProperty: #replacedParent
]

{ #category : #accessing }
DCBlock >> replacedParent: aBlock [

	self setProperty: #replacedParent toValue: aBlock
]

{ #category : #'query actions' }
DCBlock >> reportError: anError [

	self queryState reportError: anError for: self
]

{ #category : #'as yet unclassified' }
DCBlock >> resolveSource [

	^ self
]

{ #category : #'as yet unclassified' }
DCBlock >> rootBlock [

	^ self orAnyParent: self language rootRuleName
]

{ #category : #queries }
DCBlock >> run: aCollection [

	^ DCQuery script: aCollection with: self
]

{ #category : #'as yet unclassified' }
DCBlock >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	self queryState errors ifNotEmpty: [:errors | aFixBoolean ifTrue: [errors do: [:error | error tryFixIfFail: [^ false]]] ifFalse: [^ false]].
	^ true
]

{ #category : #'as yet unclassified' }
DCBlock >> shallowCopyBlock [

	^ self class new
		type: type;
		language: language;
		range: range;
		field: field;
		highlight: highlight
]

{ #category : #hierarchy }
DCBlock >> siblingIndex [

	self replacedParent ifNotNil: [^ self replacedParent siblingIndex].
	
	self parent ifNil: [^ 0].
	
	^ self parent children indexOf: self
]

{ #category : #'as yet unclassified' }
DCBlock >> slot [

	^ DCMockSlot new for: self
]

{ #category : #'as yet unclassified' }
DCBlock >> smallestBlockEncompassig: aRange [

	| min |
	min := self.
	self allBlocksDo: [:block | (block isTSMorph and: [block encompasses: aRange]) ifTrue: [min range size > block range size ifTrue: [min := block]]].
	^ min
]

{ #category : #'as yet unclassified' }
DCBlock >> startInputAtSourceIndex: aNumber [

	self allTextMorphsDo: [:m |
		(m isTSMorph and: [m range end index >= aNumber]) ifTrue: [
			^ aNumber <= m range end index
				ifTrue: [
					"we're now inside!"
					self sandblockEditor
						startInput: m containingSandblock
						at: aNumber - m range start index + 1
						replacingContents: false
						in: m]
				ifFalse: [
					"we just went past"
					self sandblockEditor
						startInput: m containingSandblock
						at: 1
						replacingContents: false
						in: m]]]
]

{ #category : #'as yet unclassified' }
DCBlock >> startInputCommandIn: aTextMorph [

	^ aTextMorph ifNotNil: [SBTextCommand new textMorph: aTextMorph] ifNil: [nil]
]

{ #category : #'as yet unclassified' }
DCBlock >> statementWithTerminatorRange [

	^ self trailingTerminator
		ifNotNil: [:t | SBTSRange merging: {self range. t range}]
		ifNil: [self range]
]

{ #category : #'as yet unclassified' }
DCBlock >> statements [

	^ self childSandblocks
]

{ #category : #'as yet unclassified' }
DCBlock >> suggestions [

	^ self queryState suggestionsFor: self
]

{ #category : #'as yet unclassified' }
DCBlock >> swap: aNumber [

	self tryApplyChange: [:source :textMorph :cursorIndex | | pivot outerPivot |
		pivot := (self sandblockEditor mode = #input
			ifTrue: [textMorph]
			ifFalse: [self]) orOwnerSuchThat: [:morph | morph owner submorphCount > 1].
		outerPivot := pivot orOwnerSuchThat: [:morph |
			(aNumber > 0
				ifTrue: [morph morphAfterThat: #isSandblock]
				ifFalse: [morph morphBeforeThat: #isSandblock]) notNil].
		outerPivot ifNotNil: [ | target startIndex targetRange pivotRange |
			target := aNumber > 0
				ifTrue: [outerPivot morphAfterThat: #isSandblock]
				ifFalse: [outerPivot morphBeforeThat: #isSandblock].
			targetRange := target statementWithTerminatorRange.
			pivotRange := pivot statementWithTerminatorRange.
			startIndex := targetRange start index + (aNumber > 0 ifTrue: [targetRange size - pivotRange size] ifFalse: [0]).
			self class
				swap: pivotRange
				with: targetRange
				in: source
				do: (self applyBlockWithCursor: (SBTSRange start: startIndex size: pivot range size))]]
]

{ #category : #'as yet unclassified' }
DCBlock >> template [

	^ self language rule: self type
]

{ #category : #'as yet unclassified' }
DCBlock >> textMorphForPosition: aPosition [

	self allChildrenDo: [:t | (t isTextMorph and: [t range contains: aPosition]) ifTrue: [^ t]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> textMorphs [

	^ self submorphs select: [:t | t isTextMorph]
]

{ #category : #'as yet unclassified' }
DCBlock >> trailingTerminator [

	| nextLeaf |
	self language isStatementTerminatorBetween ifFalse: [^ nil].
	nextLeaf := self nextMorphThat: [:m | m hasSubmorphs not].
	(nextLeaf ifNotNil: [:l | l isTSMorph ifTrue: [l treeLabel] ifFalse: ['']] ifNil: ['']) = self language statementTerminator ifTrue: [^ nextLeaf].
	^ nil
]

{ #category : #'as yet unclassified' }
DCBlock >> treeHash [

	true ifTrue: [^ self treeHashCount: {0}].
	^ self valueOfProperty: #treeHash ifAbsentPut: [self treeHashCount: {0}]
]

{ #category : #'as yet unclassified' }
DCBlock >> treeHashChildren: anotherNumber [

	^ ((((self type hash bitXor: 'ENTER' hash) bitXor: anotherNumber) bitXor: self siblingIndex hash) bitXor: self children size) bitXor: 'LEAVE' hash
]

{ #category : #'as yet unclassified' }
DCBlock >> treeHashChildren: anotherNumber countPtr: aCollection [

	aCollection at: 1 put: aCollection first + 1.
	
	^ ((((self type hash + 'ENTER' hash) + anotherNumber) bitXor: (2 * aCollection first + 1) hash) bitXor: self children size) bitXor: 'LEAVE' hash
]

{ #category : #'as yet unclassified' }
DCBlock >> treeHashCount: aPtr [

	self hasChildren ifFalse: [^ self treeHashChildren: 0 countPtr: aPtr].
	^ self
		treeHashChildren: (self children inject: 0 into: [:hash :morph | hash bitXor: (morph treeHashCount: aPtr)])
		countPtr: aPtr
]

{ #category : #'as yet unclassified' }
DCBlock >> treeLabel [

	^ ''
]

{ #category : #'as yet unclassified' }
DCBlock >> tryApplyChange: aClosure [

	| oldCursorOffset oldSource |
	oldCursorOffset := self activeTextMorph ifNotNil: #cursor.
	oldSource := self rootBlock privateSource.
	
	aClosure valueWithEnoughArguments: {
		oldSource.
		self activeTextMorph ifNil: [self].
		self activeTextMorph
			ifNotNil: [self activeTextMorph range start index + (oldCursorOffset - 1)]
			ifNil: [self range]}
]

{ #category : #'as yet unclassified' }
DCBlock >> type [

	^ type
]

{ #category : #'as yet unclassified' }
DCBlock >> type: aSymbol [

	type := aSymbol.
	
	
]

{ #category : #'as yet unclassified' }
DCBlock >> typeNewLine [
	<inputAction>

	self insert: String lf
]

{ #category : #'as yet unclassified' }
DCBlock >> updateAllHighlights [

	^ self slot updateAllHighlightsFor: self
]

{ #category : #'as yet unclassified' }
DCBlock >> useSuggestion: anItem [

	self tryApplyChange: [:source :textMorph :cursorIndex | self class replace: textMorph range in: source with: anItem source do: self applyBlock]
]

{ #category : #'as yet unclassified' }
DCBlock >> valid [

	^ self type ~= 'ERROR'
]

{ #category : #'action helpers' }
DCBlock >> wrapIn: aString [

	self wrapWithBefore: aString after: (self pairMap at: aString)
]

{ #category : #actions }
DCBlock >> wrapInBackticks [
	<action>

	self wrapIn: '`'
]

{ #category : #actions }
DCBlock >> wrapInCurlyBraces [
	<action>

	self wrapIn: '{'
]

{ #category : #actions }
DCBlock >> wrapInDoubleQuotes [
	<action>

	self wrapIn: '"'
]

{ #category : #actions }
DCBlock >> wrapInRoundParenthesis [
	<action>

	self wrapIn: '('
]

{ #category : #actions }
DCBlock >> wrapInSingleQuotes [
	<action>

	self wrapIn: ''''
]

{ #category : #actions }
DCBlock >> wrapInSquareBrackets [
	<action>

	self wrapIn: '['
]

{ #category : #'as yet unclassified' }
DCBlock >> wrapWithBefore: aString after: anotherString [

	self tryApplyChange: [:source :textMorph :cursorIndex |
		self class
			replace: textMorph range
			in: source
			with: aString, self sourceString, anotherString
			do: (self applyBlockWithCursor: textMorph range start index + aString size)]
]

{ #category : #'as yet unclassified' }
DCBlock >> writeSourceOn: aStream [

	self valueOfProperty: #tsSource ifPresentDo: [:source | ^ aStream nextPutAll: source].
	
	self assert: self rootBlock ~= self.
	
	self rootBlock
		ifNotNil: [
			aStream nextPutAll: (self rootBlock privateSource
				copyFrom: self range start index + 1
				to: self range end index)]
		ifNil: [self writeSourceOn: aStream indent: 0 forCompare: false]
]

{ #category : #'as yet unclassified' }
DCBlock >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	self children ifEmpty: [^ self].
	(self language indentMatch: self) ifTrue: [self slot indent: 1 on: aStream].
	aStream hasLineInfo ifTrue: [
		range start
			line: aStream currentLine
			character: aStream currentIndexInLine
			index: aStream position].
	self children overlappingPairsDo: [:first :second |
		first writeSourceOn: aStream indent: (self indentFor: first current: aNumber) forCompare: aBoolean.
		aStream nextPutAll: (self slot
			separatorBetween: first
			and: second
			indent: aNumber
			lastCharacterOfFirst: (aStream position > 0 ifFalse: [$ ] ifTrue: [aStream last]))].
	self children last
		writeSourceOn: aStream
		indent: (self indentFor: self children last current: aNumber)
		forCompare: aBoolean.
	aStream hasLineInfo ifTrue: [range end line: aStream currentLine character: aStream currentIndexInLine index: aStream position]
]
