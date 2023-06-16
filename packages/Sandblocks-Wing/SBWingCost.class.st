Class {
	#name : #SBWingCost,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'resource',
		'parameters'
	],
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingCost class >> replaceAllIn: aBlock [

	| map |
	map := Dictionary new.
	
	(aBlock queryAll: '(call (reference_identifier) @function)') do: [:function | (#('log' 'report') includes: function contents) ifTrue: [(function parentSandblock applyReplacement: SBWingCost) buildParameters]].
	
	(aBlock queryAll: '(new_expression) @') do: [:resource | | mappedResource p |
		p := resource parentSandblock.
		mappedResource := resource applyReplacement: SBWingCost.
		p type caseOf: {
			[#'variable_definition_statement'] -> [
				(SBWing usagesOf: (p get: #name)) do: [:use |
					use parentSandblock type caseOf: {
						[#'nested_identifier'] -> [
							(use parentSandblock parentSandblock applyReplacement: SBWingCost)
								resource: mappedResource;
								buildParameters].
						[#'variable_definition_statement'] -> ['our declaration, ignore']}]].
			[#'argument_list'] -> ['need to trace the call'].
			[#source] -> ['no further use, done.']}.
		mappedResource buildParameters].
	
	(aBlock queryAll: '(inflight_closure) @') do: [:function | (function applyReplacement: SBWingCost) buildParameters].
	
	SBWingCost updateAllIn: aBlock
]

{ #category : #'as yet unclassified' }
SBWingCost class >> updateAllIn: aBlock [

	aBlock allBlocksDo: [:b | b class = self ifTrue: [b update]]
]

{ #category : #accessing }
SBWingCost >> allResourceUses [
	"add support for function calls"

	self flag: #todo.
	
	self parentSandblock type = #'variable_definition_statement' ifTrue: [^ self toplevel allBlocksSelect: [:b | b class = self class and: [b resource = self and: [b reachable]]]].
	
	^ {}
]

{ #category : #accessing }
SBWingCost >> apiCallName [

	^ (bindings at: 'function') contents
]

{ #category : #'as yet unclassified' }
SBWingCost >> artefactChanged: aMethodBlock [

	self containingArtefact = aMethodBlock ifTrue: [self update]
]

{ #category : #parameters }
SBWingCost >> averageRecordSize [

	^ SBWingParameterNumber new
		icon: SBIcon iconFile;
		name: #averageRecordSize;
		suffix: ' Byte average record size';
		initial: 100
]

{ #category : #parameters }
SBWingCost >> averageRequestResponseSize [

	^ SBWingParameterNumber new
		icon: SBIcon iconFile;
		name: #averageRequestResponseSize;
		suffix: ' Byte average request plus response size';
		initial: 500
]

{ #category : #'parameter helpers' }
SBWingCost >> buildParameters [

	self relevantParameters do: [:parameter |
		self addMorph: (parameter from: self) inFrontOf: self lastSubmorph.
		parameter update]
]

{ #category : #queries }
SBWingCost >> buildWithParameters [
	<lang: #wing match: '(structured_access_expression
	(array_literal
[
(string) ="cost"
(call (reference_identifier) @static_function)
(new_expression (custom_type) @type)
(call (nested_identifier (member_identifier) @function))
(inflight_closure) @closure
] @nested
	(map_literal) @parameters))' sample: '["cost", inflight () => {}, {test: 12}][0]'>

	self addMorphBack: (self createBindingBlock: 'nested')
]

{ #category : #queries }
SBWingCost >> buildWithoutParameters [
	<lang: #wing match: '[
(call (reference_identifier) @static_function)
(new_expression (custom_type) @type)
(call (nested_identifier (member_identifier) @function))
(inflight_closure) @closure
]' sample: 'inflight () => {}'>

	| newRoot oldRoot |
	"guard against wrapping a cost that already has parameters (see other matching rule)"
	(self root parentSandblock notNil and: [
		self root parentSandblock type = #'array_literal' and: [
			self root parentSandblock childSandblocks
				ifNotEmpty: [:s | s first contents = 'cost']
				ifEmpty: [false]]]) ifTrue: [^ nil].
	
	oldRoot := self createBindingBlock: 'root'.
	newRoot := self language parseExpression: '["cost", a, {}][0]'.
	bindings at: 'parameters' put: (newRoot queryNode: '(map_literal) @').
	
	(newRoot queryNode: '(reference_identifier) ="a" @') replaceBlock: oldRoot.
	bindings at: 'root' put: newRoot.
	
	self addMorphBack: oldRoot
]

{ #category : #parameters }
SBWingCost >> closureParameters [

	^ {
		SBWingParameterNumber new
			icon: SBIcon iconFile;
			name: #memory;
			suffix: ' MB';
			initial: 128.
		SBWingParameterNumber new
			icon: SBIcon iconClockO;
			name: #averageDuration;
			suffix: ' sec';
			initial: 0.1.
		SBWingParameterNumber new
			icon: SBIcon iconCompass;
			name: #cores;
			suffix: ' cores';
			initial: 2.
		self costPerMonth: [(self get: #cores) * (self get: #averageDuration) * (self get: #memory) * self numberOfInvocations * 0.0001]}
]

{ #category : #parameters }
SBWingCost >> costPerInvocation: aNumber [

	^ self costPerMonth: [self numberOfInvocations * aNumber]
]

{ #category : #parameters }
SBWingCost >> costPerMonth: aBlock [

	^ SBWingParameterCost new
		icon: SBIcon iconMoney;
		name: #cost;
		value: aBlock;
		label: [:v | '${1} / month' format: {v printShowingDecimalPlaces: 2}]
]

{ #category : #parameters }
SBWingCost >> editableNumInvocations [

	^ SBWingParameterNumber new
		icon: SBIcon iconHashtag;
		name: #numberOfInvocations;
		suffix: ' invocations / month';
		initial: 100
]

{ #category : #accessing }
SBWingCost >> get: aParameter [

	^ self parameterMorphs detect: [:param | param name = aParameter] ifFound: #value ifNone: [0]
]

{ #category : #initialization }
SBWingCost >> initialize [

	super initialize.
	
	parameters := Dictionary new.
	self layoutInset: 8.
	self layoutPolicy: SBAlgebraLayout new
]

{ #category : #accessing }
SBWingCost >> isAPICall [

	^ bindings includesKey: 'function'
]

{ #category : #accessing }
SBWingCost >> isStaticCall [

	^ bindings includesKey: 'static_function'
]

{ #category : #layout }
SBWingCost >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs
			collect: [:s | s layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true]);
		morph: self
]

{ #category : #parameters }
SBWingCost >> numInvocationsNamed: aString [

	^ SBWingParameterDerived new
		icon: SBIcon iconHashtag;
		name: #numberOfInvocations;
		value: [self numberOfInvocations];
		label: [:v | '{1} {2}' format: {v. aString}]
]

{ #category : #accessing }
SBWingCost >> numberOfInvocations [

	self isAPICall ifTrue: [((self resourceName = 'cloud.Api' and: [#('post' 'get') includes: self apiCallName]) or: [self resourceName = 'cloud.Table' and: [#('on' 'get') includes: self apiCallName]]) ifTrue: [^ self get: #numberOfInvocations]].
	
	^ (Array streamContents: [:s | (self orOwnerSuchThat: [:o | o isTSBlock and: [o type = #'inflight_closure']]) ifNotNil: [:closure | self numberOfInvocations: closure parentSandblock on: s]])
		inject: 0
		into: [:sum :block | sum + block numberOfInvocations]
]

{ #category : #accessing }
SBWingCost >> numberOfInvocations: aBlock on: aStream [

	| p |
	p := aBlock parentSandblock.
	(aBlock isTSReplacement and: [aBlock type = #call]) ifTrue: [
		aStream nextPut: aBlock.
		^ self numberOfInvocations: p on: aStream].
	
	aBlock type
		caseOf: {
			[#source] -> [^ self].
			[#'variable_definition_statement'] -> [
				^ self language
					usagesOf: (aBlock get: #name)
					do: [:use | use parentSandblock = aBlock ifFalse: [self numberOfInvocations: use on: aStream]]]}
		otherwise: [^ self numberOfInvocations: p on: aStream]
]

{ #category : #'parameter helpers' }
SBWingCost >> parameterMorphs [

	^ self submorphs viewAllButLast
]

{ #category : #parameters }
SBWingCost >> parameters [

	^ Dictionary newFrom: {
		{'log'} -> [{self numInvocationsNamed: 'logs'. self costPerInvocation: 0.02}].
		{'report'} -> [
			{
				self costPerMonth: [
					(Array streamContents: [:s | self toplevel allMorphsDo: [:b | (b class = SBWingParameterCost and: [b owner ~= self]) ifTrue: [s nextPut: b]]])
						inject: 0
						into: [:sum :cost | sum + cost value]]}].
		{'inflight_closure'} -> [self closureParameters].
		{'cloud.Api'} -> [
			{
				SBWingParameterDerived new
					icon: SBIcon iconHashtag;
					name: #bandwidthUse;
					value: [
						self allResourceUses
							inject: 0
							into: [:sum :endpoint | sum + (endpoint numberOfInvocations * (endpoint get: #averageRequestResponseSize))]];
					label: [:v | '{1}B bandwidth use / month' format: {v}].
				self costPerMonth: [(self get: #bandwidthUse) * 0.003]}].
		{'cloud.Table'. 'insert'} -> [{self averageRecordSize. self numInvocationsNamed: 'writes'. self costPerInvocation: 0.01}].
		{'cloud.Table'. 'list'} -> [{self averageRecordSize. self numInvocationsNamed: 'reads'. self costPerInvocation: 0.01}].
		{'cloud.Table'. 'on'} -> [
			{
				SBWingParameterDerived new
					icon: SBIcon iconHashtag;
					name: #numberOfInvocations;
					value: [
						(self resource allResourceUses select: [:use | use apiCallName = 'insert'])
							inject: 0
							into: [:sum :insert | sum + insert numberOfInvocations]];
					label: [:v | '{1} triggers' format: {v}]}].
		{'cloud.Table'} -> [
			{
				SBWingParameterDerived new
					icon: SBIcon iconFile;
					name: #insertBytesPerMonth;
					value: [
						(self allResourceUses select: [:use | use apiCallName = 'insert'])
							inject: 0
							into: [:sum :insert | sum + (insert numberOfInvocations * (insert get: #averageRecordSize))]];
					label: [:v | 'Storage: adding {1} Bytes each month' format: {v}]}].
		{'cloud.Api'. 'get'} -> [{self editableNumInvocations. self averageRequestResponseSize}].
		{'cloud.Api'. 'post'} -> [{self editableNumInvocations. self averageRequestResponseSize}]}
]

{ #category : #accessing }
SBWingCost >> reachable [

	| current |
	current := self.
	[current ~= self toplevel] whileTrue: [
		current parentSandblock class = SBToggle ifTrue: [current firstSubmorph value ifFalse: [^ false]].
		current := current parentSandblock].
	^ true
]

{ #category : #'parameter helpers' }
SBWingCost >> relevantParameters [

	bindings
		at: 'closure'
		ifPresent: [:c | ^ (self parameters at: {'inflight_closure'} ifAbsent: [{}]) value].
	bindings
		at: 'static_function'
		ifPresent: [:function | ^ (self parameters at: {function contents} ifAbsent: [{}]) value].
	bindings
		at: 'function'
		ifPresent: [:function | ^ (self parameters at: {self resourceName. function contents} ifAbsent: [{}]) value].
	bindings
		at: 'type'
		ifPresent: [:type | ^ (self parameters at: {type sourceString} ifAbsent: [{}]) value]
]

{ #category : #accessing }
SBWingCost >> resource [

	^ resource
]

{ #category : #accessing }
SBWingCost >> resource: aBlock [

	resource := aBlock
]

{ #category : #accessing }
SBWingCost >> resourceName [

	resource ifNotNil: [^ resource resourceName].
	self assert: (bindings includesKey: 'type').
	^ (bindings at: 'type') sourceString
]

{ #category : #'parameter helpers' }
SBWingCost >> update [

	self hasSubmorphs ifTrue: [self submorphs allButLast do: #update]
]

{ #category : #'parameter helpers' }
SBWingCost >> updateAll [

	self class updateAllIn: self toplevel
]

{ #category : #copying }
SBWingCost >> veryDeepInner: deepCopier [

	super veryDeepInner: deepCopier.
	parameters := parameters veryDeepCopyWith: deepCopier
]
