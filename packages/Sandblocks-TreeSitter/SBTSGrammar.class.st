Class {
	#name : #SBTSGrammar,
	#superclass : #Object,
	#instVars : [
		'rules',
		'supertypes',
		'inlinedRules',
		'delimitedRepeats',
		'aliasOccurrences'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #cleaning }
SBTSGrammar >> applyInlining: aRule grammar: aGrammarJson [

	aRule allChildrenDo: [:node |
		(node isTSSymbol and: [
			(aGrammarJson inline includes: node name) and: [
				SBToggledCode
					comment: ''
					active: 2
					do: {[true]. [(aGrammarJson supertypes includes: node name) not]}]]) ifTrue: [ | inline |
			inline := rules at: node name.
			node replaceBy: inline copy.
			^ self].
		(node isTSSymbol and: [node type first = $_ and: [(aGrammarJson externals noneSatisfy: [:e | e name = node name]) and: [(aGrammarJson supertypes includes: node name) not]]]) ifTrue: [ | inline |
			inline := aGrammarJson rules at: node name.
			(self includesNonHiddenParts: inline visited: Set new) ifTrue: [node replaceBy: inline copy].
			^ self]]
]

{ #category : #cleaning }
SBTSGrammar >> autofixExternals: aGrammar [

	| externals |
	externals := (aGrammar externals select: [:rule | rule type = 'SYMBOL']) collect: #name.
	externals do: [:external |
		rules at: external ifAbsent: [
			rules do: [:rule |
				rule
					allChildrenDetect: [:obj | obj isTSAlias and: obj element type = external]
					ifFound: [:alias | rules at: external put: (SBTSNodeLabel new label: alias alias)]
					ifNone: []]]].
	
	(aGrammar externals select: [:rule | rule type = 'STRING']) do: [:external |
		rules
			at: external value
			ifAbsent: [rules at: external value put: (SBTSNodeLabel new label: external value)]].
	
	(externals reject: [:external | rules includesKey: external]) ifNotEmpty: [:missing | UIManager default inform: 'Missing declarations for: ', (missing joinSeparatedBy: ', ')]
]

{ #category : #cleaning }
SBTSGrammar >> blanksToOptionals: aRule [
	"(A|_BLANK_) -> A?"

	aRule allChildrenDo: [:node |
		(node isTSChoice and: [node elements size = 2 and: [node elements second isTSBlank]]) ifTrue: [
			node replaceBy: node elements second.
			node elements second required: true]]
]

{ #category : #accessing }
SBTSGrammar >> bodyNodeForRule: aString [

	^ self bodyNodeForRule: aString ifAbsent: [^ self error: 'no such rule: ', aString]
]

{ #category : #accessing }
SBTSGrammar >> bodyNodeForRule: aString ifAbsent: aBlock [

	((self inlinedRules includes: aString) and: [(supertypes includes: aString) not]) ifTrue: [^ aBlock value].
	^ rules at: aString ifAbsent: aBlock
]

{ #category : #helper }
SBTSGrammar >> buildNodesFor: anObject [

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
		SBToggledCode comment: '' active: 0 do: {
			[
				(anObject members size = 2 and: [anObject members second type = 'BLANK']) ifTrue: [
					^ SBTSNodeRepeat new
						multiple: false required: false element: (self buildNodesFor: anObject members first);
						factory: self]]}.
		^ SBTSNodeChoice new
			alternatives: (anObject members collect: [:member | self buildNodesFor: member]);
			factory: self].
	'SEQ' = anObject type ifTrue: [
		^ SBTSNodeSeq new
			factory: self;
			elements: (anObject members collect: [:member | self buildNodesFor: member])].
	'BLANK' = anObject type ifTrue: [^ SBTSNodeBlank new].
	self assert: false
]

{ #category : #helper }
SBTSGrammar >> buildRegex: anObject on: aStream [

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
SBTSGrammar >> buildRegexString: rule [

	| s |
	s := '' writeStream.
	self buildRegex: rule on: s.
	^ ((s contents copyReplaceAll: '\p{XID_Start}' with: 'A-Za-z')
		copyReplaceAll: '\p{XID_Continue}'
		with: 'A-Za-z0-9')
		copyReplaceAll: ':'
		with: '\:'
]

{ #category : #cleaning }
SBTSGrammar >> checkStructure: anObject [

	anObject allChildrenDo: [:node | self assert: (node isTSChoice not or: [node elements notEmpty])]
]

{ #category : #helper }
SBTSGrammar >> escapeStringForRegex: aString [

	^ aString copyWithRegex: '[.*+?^${}()|\[\]\\]' matchesTranslatedUsing: [:m | '\', m]
]

{ #category : #cleaning }
SBTSGrammar >> flattenSeparatedList: anObject [

	| looksLikeSepList looksLikeOptionalSep |
	looksLikeSepList := [:obj |
		obj isTSSeq and: [
			obj elements size = 2 and: [ | second |
				second := obj elements second.
				second isTSRepeat and: [second element isTSSeq and: [obj elements first hasEqualStructure: obj elements second element elements second]]]]].
	looksLikeOptionalSep := [:obj | obj isTSChoice and: [obj alternatives second isTSBlank and: [obj alternatives first isTSLabel]]].
	anObject allChildrenDo: [:node |
		" seq(seq(rule, repeat(seq(separator, rule))), (separator|blank)) "
		(node isTSSeq and: [(looksLikeSepList value: node elements first) and: [looksLikeOptionalSep value: node elements second]]) ifTrue: [ | repeater |
			repeater := SBTSNodeRepeat new
				multiple: true
				required: false
				element: node elements first elements first.
			repeater delimiter: node elements second elements first label.
			node replaceBy: repeater].
		" seq(rule, repeat(seq(separator, rule))) "
		(looksLikeSepList value: node) ifTrue: [ | repeater |
			repeater := SBTSNodeRepeat new
				multiple: true
				required: true
				element: node elements second elements first elements second.
			repeater delimiter: node elements second element elements first label.
			node replaceBy: repeater]]
]

{ #category : #cleaning }
SBTSGrammar >> includesNonHiddenParts: anObject visited: aCollection [

	^ true
]

{ #category : #accessing }
SBTSGrammar >> inlinedRules [

	^ inlinedRules
]

{ #category : #testing }
SBTSGrammar >> isBlockInlined: aSymbol [

	^ false
]

{ #category : #testing }
SBTSGrammar >> isSuperType: aSymbol [

	^ supertypes includes: aSymbol
]

{ #category : #cleaning }
SBTSGrammar >> mergeAdjacentOptions: anObject [
	" look for (element | element*) and change to element+ "

	anObject allChildrenDo: [:node |
		node isTSChoice ifTrue: [
			node elements copy do: [:alt |
				(alt isTSRepeat and: [alt element isTSSymbol]) ifTrue: [
					node elements do: [:otherAlt |
						(otherAlt isTSSymbol and: [alt element type = otherAlt type]) ifTrue: [
							alt required: true.
							node elements: (node elements copyWithout: otherAlt)]]]]]]
]

{ #category : #cleaning }
SBTSGrammar >> mergeNestedChoices: anObject [
	" (a | (b | c)) -> (a | b | c) "

	anObject allChildrenDo: [:choice |
		choice isTSChoice ifTrue: [
			(choice elements noneSatisfy: #isTSBlank) ifTrue: [
				choice elements: (Array streamContents: [:stream |
					choice elements do: [:nested |
						(nested isTSChoice and: [nested elements noneSatisfy: [:m | m isTSBlank]])
							ifTrue: [stream nextPutAll: nested elements]
							ifFalse: [stream nextPut: nested]]])]]]
]

{ #category : #cleaning }
SBTSGrammar >> mergeOptionalRepeat: anObject [

	anObject allChildrenDo: [:node |
		(node isTSChoice and: [node elements size = 2 and: [node elements first isTSRepeat and: [node elements second isTSBlank]]]) ifTrue: [
			node replaceBy: (node elements first
				required: false;
				yourself)].
		(node isTSRepeat and: [node element isTSChoice and: [node element elements size = 2 and: [node element elements second isTSBlank]]]) ifTrue: [
			node element replaceBy: node element elements first.
			node required: false]]
]

{ #category : #cleaning }
SBTSGrammar >> mergeRedundantRepeats: anObject [
	" (a* | b+)* -> (a | b)* "

	anObject allChildrenDo: [:node | (node isTSRepeat and: [node element isTSChoice]) ifTrue: [node element elements do: [:m | m isTSRepeat ifTrue: [m replaceBy: m element]]]]
]

{ #category : #cleaning }
SBTSGrammar >> mergeRepeats: aRule [
	"AA* -> A+"

	aRule allChildrenDo: [:node |
		(node isTSSeq and: [
			node elements size = 2 and: [ | first second |
				first := node elements first.
				second := node elements second.
				first isTSSymbol and: [second isTSRepeat and: [first type = second element type]]]]) ifTrue: [
			node replaceBy: node elements second.
			node elements second required: true]]
]

{ #category : #cleaning }
SBTSGrammar >> noteAliases: anObject name: aString [

	anObject allChildrenDo: [:node |
		node isTSAlias ifTrue: [
			aliasOccurrences add: (SBTSAlias new
				name: node value;
				object: node element copy;
				parentType: aString)]]
]

{ #category : #cleaning }
SBTSGrammar >> prepareGrammar: aJSONGrammar [

	self example: [SBTSGrammar new] args: [{SBTSSmalltalk grammarJsonObject}] label: 'example'.
	supertypes := aJSONGrammar supertypes.
	inlinedRules := aJSONGrammar at: 'inline'.
	rules := aJSONGrammar rules
		collect: [:rule | self buildNodesFor: rule]
		as: Dictionary.
	SBToggledCode comment: '' active: 1 do: {[self autofixExternals: aJSONGrammar]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self removeExternals: rule grammar: aJSONGrammar]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules keysAndValuesDo: [:name :rule | self removeHiddenTerminals: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self unwrapSingleChoices: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self removeHiddenTerminals: rule]]}.
	SBToggledCode comment: '' active: 1 do: {[self rules do: [:rule | self simplifyList: rule]]}.
	SBToggledCode comment: '' active: 1 do: {[self rules do: [:rule | self mergeRepeats: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules keysAndValuesDo: [:name :rule | self flattenSeparatedList: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules keysAndValuesDo: [:name :rule | self applyInlining: rule grammar: aJSONGrammar]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules keysAndValuesDo: [:name :rule | self applyInlining: rule grammar: aJSONGrammar]]}.
	SBToggledCode comment: '' active: 0 do: {
		[" depends on inlining, requires removing blanks (hidden terminals) "
		self rules keysAndValuesDo: [:name :rule | delimitedRules at: name ifPresent: [:r | self removeMarkedDelimiters: rule rule: name]]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self mergeRedundantRepeats: rule]]}.
	SBToggledCode comment: '' active: 1 do: {
		[
			self rules keysAndValuesDo: [:name :rule |
				SBToggledCode
					comment: ''
					active: 1
					do: {[self noteAliases: rule name: name]. [self removeAliases: rule]}]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self unwrapSingleChoices: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self mergeOptionalRepeat: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self removeDuplicateAlternatives: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self mergeNestedChoices: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self mergeAdjacentOptions: rule]]}.
	SBToggledCode
		comment: ''
		active: 1
		do: {[self rules do: [:rule | self removeHiddenTerminals: rule]]}.
	self rules do: [:rule | self checkStructure: rule]
]

{ #category : #cleaning }
SBTSGrammar >> removeDuplicateAlternatives: anObject [
	" TODO: only removes SYMBOL duplicates "

	anObject allChildrenDo: [:node |
		(node isTSChoice and: [node elements allSatisfy: #isTSSymbol]) ifTrue: [ | symbols |
			symbols := node elements collect: #type.
			symbols size ~= symbols withoutDuplicates size ifTrue: [node elements: node elements withoutDuplicates]]]
]

{ #category : #cleaning }
SBTSGrammar >> removeExternals: aRule grammar: aJSONGrammar [

	aRule allChildrenDo: [:node | | skipChildBlock |
		skipChildBlock := [:child | child isTSSymbol and: [(aJSONGrammar externals anySatisfy: [:external | external name = child type]) and: [((aJSONGrammar at: #inline) includes: child type) not and: [(aJSONGrammar rules includesKey: child type) not]]]].
		
		node isTSChoice ifTrue: [node alternatives: (node alternatives reject: skipChildBlock)].
		node isTSSeq ifTrue: [node elements: (node elements reject: skipChildBlock)]]
]

{ #category : #cleaning }
SBTSGrammar >> removeHiddenTerminals: aRule [

	aRule allChildrenDo: [:node | | skipChildBlock |
		skipChildBlock := [:child | (child isTSSymbol and: [(self includesNonHiddenParts: child visited: Set new) not]) or: [node isTSSeq and: [child isTSBlank]]].
		node isTSChoice ifTrue: [node alternatives: (node alternatives reject: skipChildBlock)].
		node isTSSeq ifTrue: [node elements: (node elements reject: skipChildBlock)]]
]

{ #category : #accessing }
SBTSGrammar >> rules [

	^ rules
]

{ #category : #cleaning }
SBTSGrammar >> simplifyList: anObject [
	" make a*? to a* "

	anObject allChildrenDo: [:node | (node isTSChoice and: [node elements size = 2 and: [node elements last isTSBlank and: [node elements first isTSRepeat]]]) ifTrue: [node replaceBy: node members first]]
]

{ #category : #helper }
SBTSGrammar >> unpackTypes [

	^ #('PREC_RIGHT' 'PREC_LEFT' 'PREC_DYNAMIC' 'PREC' 'ALIAS' 'FIELD')
]

{ #category : #cleaning }
SBTSGrammar >> unwrapSingleChoices: anObject [
	" (a) -> a, (a* | BLANK) -> a* "

	anObject allChildrenDo: [:node |
		(node isTSChoice and: [node alternatives size = 1]) ifTrue: [node replaceBy: node alternatives anyOne].
		(node isTSChoice and: [
			node alternatives size = 2 and: [ | first second |
				first := node alternatives first.
				second := node alternatives second.
				first isTSRepeat and: [first multiple and: [first required not and: [second isTSBlank]]]]]) ifTrue: [node replaceBy: node elements first].
		(node isTSSeq and: [node elements size = 1]) ifTrue: [node replaceBy: node elements anyOne]]
]
