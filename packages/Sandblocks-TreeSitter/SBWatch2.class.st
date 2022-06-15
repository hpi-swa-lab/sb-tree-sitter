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

	| source |
	source := aBlock language runtime
		buildWatchSourceFor: aBlock
		id: UUID new asString.
	^ source applyReplacement
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
    .connect(process.env.SQ_WATCH, "localhost")
    .end(
      JSON.stringify({
        id: "8760eb08-6e29-47e6-a1fc-78d5c8bcb9fb",
        expression: require("util").inspect(e),
      })
    ),
  e
))(req.path);'>

	self id: (self bindings at: 'id') contents.
	self addMorphFront: (self createBindingBlock: 'expression')
]

{ #category : #'as yet unclassified' }
SBWatch2 >> buildPython [
	<lang: #python match: '(subscript (call (parenthesized_expression (lambda (_ (_ (_
	(lambda (tuple (call (argument_list (call (attribute (parenthesized_expression (binary_operator (binary_operator (string) @string)))))))))))))) (argument_list (_) @expression))) @watch' sample: 'print(
        (lambda e: ((lambda s: (s.connect(("localhost", int(__import__("os").environ["SQ_WATCH"]))), s.send(
    ("{\"id\":\"08cd4b51-8b2d-4d6a-8a2b-c1728c42cd3a\",\"expression\":"+str(e)+"}").encode()), s.close()))(__import__("socket").socket()), e))(2)[1])+2'>

	self id: ((((self bindings at: 'string') sourceString allRegexMatches: '\\"id\\"\:\\"([^\\]+)\\"') first
		allButFirst: 9) allButLast: 2).
	
	self addMorphFront: (self createBindingBlock: 'expression')
]

{ #category : #'as yet unclassified' }
SBWatch2 >> buildSmalltalk [
	<lang: #smalltalk match: '(keyword_message (identifier) ="SBWatch2" (expression) @expression (string) @id)' sample: 'a SBTSWatch report: x for: ''y'''>

	self id: (self bindings at: 'id') textMorphs second contents.
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

	^ self firstSubmorph
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
