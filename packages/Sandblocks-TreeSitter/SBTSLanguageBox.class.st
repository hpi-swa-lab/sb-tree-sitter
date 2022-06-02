Class {
	#name : #SBTSLanguageBox,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSLanguageBox >> build [

	| language |
	language := SBGrammarLanguage allSubclasses detect: [:lang | lang language = (bindings at: 'language') contents].
	self addMorphBack: language iconMorph.
	self addMorphBack: (self
		createBinding: [:c | SBTSFileParser new parse: (c at: 'code') contents language: language]
		update: [:c :m | (c at: 'code') contents: m sourceString])
]

{ #category : #'as yet unclassified' }
SBTSLanguageBox >> buildClojure [
	<lang: #clojure match: '(list_lit (sym_lit) ="polyglot-eval" (str_lit) @language (str_lit) @code)' sample: '(polyglot-eval "js" "some-code")'>

	
	bindings at: 'language' put: (SBTSBindingProxy trimQuotes: (bindings at: 'language')).
	bindings at: 'code' put: (SBTSBindingProxy trimQuotes: (bindings at: 'code')).
	
	self build
]

{ #category : #'as yet unclassified' }
SBTSLanguageBox >> buildJs [
	<lang: #javascript match: '(call_expression (member_expression (identifier) ="Polyglot" property: (_) ="eval") (string (_) (_) @language) [(string (_) (_) @code) (template_string (_) (_) @code)])' sample: 'Polyglot.eval("somelang", "code")'>

	self build
]

{ #category : #'as yet unclassified' }
SBTSLanguageBox >> buildPython [
	<lang: #python match: '(call
	(attribute (identifier) ="polyglot" (identifier) ="eval")
	(argument_list
		(keyword_argument (identifier) ="language" (string (string_content) @language))
		(keyword_argument (identifier) ="string" (string (string_content) @code))) @x)' sample: 'polyglot.eval(language="somelang", string="""code""")'>

	self build
]

{ #category : #'as yet unclassified' }
SBTSLanguageBox >> initialize [

	super initialize.
	
	self layoutPolicy: SBAlgebraLayout new
]

{ #category : #'as yet unclassified' }
SBTSLanguageBox >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs
			collect: [:s | s layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true]);
		morph: self
]

{ #category : #'as yet unclassified' }
SBTSLanguageBox >> wantsExtraSpace [

	^ true
]
