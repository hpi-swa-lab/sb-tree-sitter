Class {
	#name : #SBWatch2,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'id',
		'exampleValues'
	],
	#classVars : [
		'Watches'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBWatch2 class >> newEmptyFor: aBlock [

	^ SBWatch2 buildFor: aBlock language with: (Dictionary new
		at: 'id' put: UUID new asString;
		at: 'wrap' put: aBlock;
		yourself)
]

{ #category : #'as yet unclassified' }
SBWatch2 class >> registerWatch: aWatch [

	Watches := Watches ifNil: [WeakArray with: aWatch] ifNotNil: [Watches copyWith: aWatch]
]

{ #category : #'as yet unclassified' }
SBWatch2 class >> report: anObject for: anId [

	self watches do: [:watch | watch ifNotNil: [watch id = anId ifTrue: [watch reportValue: anObject env: SBExecutionEnvironment value]]].
	^ anObject
]

{ #category : #'as yet unclassified' }
SBWatch2 class >> reportId: aString value: aValueString env: anEnvironment [

	self watches do: [:watch | watch ifNotNil: [watch id = aString ifTrue: [watch reportValue: aValueString env: anEnvironment]]]
]

{ #category : #'as yet unclassified' }
SBWatch2 class >> watches [

	^ Watches ifNil: [Watches := WeakArray new]
]

{ #category : #'as yet unclassified' }
SBWatch2 >> buildJavascript [
	<lang: #javascript match: '(call_expression (parenthesized_expression (arrow_function (parenthesized_expression (sequence_expression (call_expression (call_expression (object (pair key: (_) ="id" (string (_) @id))))))))) (_) @expression) @root' sample: '((e) => (
  require("net")
    .connect(process.env.SQ_WATCH, "127.0.0.1")
    .end(
      JSON.stringify({
        id: "__id__",
        expression: e,
      })
    ),
  e
))(__wrap__);'>

	self id: (self bindings at: 'id') contents.
	self addMorphFront: (self createBindingBlock: 'expression')
]

{ #category : #'as yet unclassified' }
SBWatch2 >> buildPython [
	<lang: #python match: '(subscript (call (parenthesized_expression (lambda (_ (_ (_
	(lambda (tuple (call (argument_list (call (attribute (call (argument_list (dictionary (pair (string) ="id" (_) @id))))))))))))))) (argument_list (_) @expression))) @watch' sample: '(lambda e:((lambda s:(s.connect(("localhost",int(__import__("os").environ["SQ_WATCH"]))),s.send(__import__("json").dumps({"id":"__id__","expression":str(e)}).encode()),s.close()))(__import__("socket").socket()),e))(__wrap__)[1]'>

	self id: (self bindings at: 'id') contents.
	
	self addMorphFront: (self createBindingBlock: 'expression')
]

{ #category : #'as yet unclassified' }
SBWatch2 >> buildSmalltalk [
	<lang: #smalltalk match: '(keyword_message (identifier) ="SBWatch2" (expression) @expression (string) @id)' sample: 'a SBWatch2 report: __wrap__ for: ''__id__'''>

	self id: (self bindings at: 'id') contents.
	self addMorphFront: (self createBindingBlock: 'expression')
]

{ #category : #'as yet unclassified' }
SBWatch2 >> buildTypescript [
	<lang: #typescript match: '(call_expression (_ (_ (_ (_ (_ (_ (_ (_ (object (pair key: (_) ="id" (string (_) @id))))))))))) (_) @expression)' sample: '((e) => (
  require("net")
    .connect(process.env.SQ_WATCH, "localhost")
    .end(
      JSON.stringify({
        id: "__id__",
        expression: require("util").inspect(e),
      })
    ),
  e
))(__wrap__);'>

	self id: (self bindings at: 'id') contents.
	self addMorphFront: (self createBindingBlock: 'expression')
]

{ #category : #'as yet unclassified' }
SBWatch2 >> buildTypescriptWeb [
	<lang: #typescript match: '(call_expression (_ (_ (_ (_ (_ (_ (_ (_ (string (_) @id))))))))) (_ (_) @expression))' sample: '(<T>(e: T) => (fetch(`http://localhost:51234/sqReport?id=${"__id__"}&expression=${escape(JSON.stringify(e))}`), e))(__wrap__)'>

	self id: (self bindings at: 'id') contents.
	self addMorphFront: (self createBindingBlock: 'expression')
]

{ #category : #'as yet unclassified' }
SBWatch2 >> drawnColor [

	^ self colorPolicy toolColorFor: self
]

{ #category : #'as yet unclassified' }
SBWatch2 >> exampleFinished: anExample [

	exampleValues at: anExample ifPresent: [:val | val exampleFinished: anExample]
]

{ #category : #'as yet unclassified' }
SBWatch2 >> exampleStarting: anExample [

	(exampleValues at: anExample ifAbsentPut: [ | display |
		display := SBExampleValueDisplay new.
		self addMorphBack: (exampleValues at: anExample put: display).
		anExample ifNotNil: [anExample when: #outOfWorld send: #exampleStopped: to: self with: anExample].
		display])
		exampleStarting: anExample;
		name: (anExample ifNotNil: #label ifNil: ['global'])
]

{ #category : #'as yet unclassified' }
SBWatch2 >> exampleStopped: anExample [

	exampleValues at: anExample ifPresent: [:val |
		self removeMorph: val.
		exampleValues removeKey: anExample]
]

{ #category : #'as yet unclassified' }
SBWatch2 >> expression [

	^ self firstSubmorph firstSubmorph
]

{ #category : #'as yet unclassified' }
SBWatch2 >> id [

	^ id
]

{ #category : #'as yet unclassified' }
SBWatch2 >> id: aString [

	id ifNotNil: [^ self error: 'watch already has an id'].
	id := aString.
	self registerWatch
]

{ #category : #'as yet unclassified' }
SBWatch2 >> initialize [

	super initialize.
	exampleValues := Dictionary new.
	self
		layoutInset: 4;
		layoutPolicy: SBAlgebraLayout new;
		listDirection: #topToBottom
]

{ #category : #'as yet unclassified' }
SBWatch2 >> intoWorld: aWorld [

	| editor |
	editor := self sandblockEditor.
	(editor respondsTo: #examples) ifTrue: [editor examples registerWatch: self]
]

{ #category : #'as yet unclassified' }
SBWatch2 >> isWatch [

	^ true
]

{ #category : #'as yet unclassified' }
SBWatch2 >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs
			collect: [:m | m layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true])
]

{ #category : #'as yet unclassified' }
SBWatch2 >> listensToExamples [

	^ true
]

{ #category : #'as yet unclassified' }
SBWatch2 >> registerWatch [

	self class registerWatch: self
]

{ #category : #'as yet unclassified' }
SBWatch2 >> reportValue: aString env: anEnvironment [

	(anEnvironment isNil and: [(exampleValues includesKey: nil) not]) ifTrue: [self exampleStarting: anEnvironment].
	
	exampleValues at: anEnvironment ifPresent: [:display | | converted |
		converted := (aString isString and: [aString matchesRegex: '-?\d+(\.\d+)?'])
			ifTrue: [aString asNumber]
			ifFalse: [aString].
		converted = 'inf' ifTrue: [converted := Float infinity].
		
		display reportValue: converted name: (anEnvironment ifNotNil: #label ifNil: [''])].
	self triggerEvent: #reportedValue with: aString
]

{ #category : #'as yet unclassified' }
SBWatch2 >> veryDeepCopyWith: deepCopier [

	| newInstance |
	newInstance := super veryDeepCopyWith: deepCopier.
	newInstance registerWatch.
	^ newInstance
]
