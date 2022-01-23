Class {
	#name : #SBTSWatch,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'id'
	],
	#classVars : [
		'Watches'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #matchers }
SBTSWatch class >> matchC: aDictionary do: aBlock [
	<lang: #c match: '(call_expression (identifier) ="SQ_REPORT"
	(argument_list (string_literal) @id (_) @expr)) @watch' sample: '  return SQ_REPORT("c240af77-4dc3-47b3-b650-972ad52f1278", 2 + 3);'>

	^ aBlock
		value: (aDictionary at: 'watch')
		value: (self new id: (aDictionary at: 'id') contents expression: (aDictionary at: 'expr'))
]

{ #category : #matchers }
SBTSWatch class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(call_expression (parenthesized_expression
	(arrow_function (_(_ 
		(call_expression (member_expression
			(call_expression (member_expression
				(call_expression (identifier) ="require" (arguments (string (unescaped_double_string_fragment) ="net")))
				(property_identifier) ="connect"))
			(property_identifier) ="end")
			(arguments
				(call_expression (arguments (object
					(pair (property_identifier) ="id" (string (unescaped_double_string_fragment) @id))
					(pair (property_identifier) ="expression"))))))))))
	(arguments (_) @expression)
) @watch' sample: '((e) => (
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

	^ aBlock
		value: (aDictionary at: 'watch')
		value: (self new id: (aDictionary at: 'id') contents expression: (aDictionary at: 'expression'))
]

{ #category : #matchers }
SBTSWatch class >> matchPy: aDictionary do: aBlock [
	<lang: #python match: '(subscript (call (parenthesized_expression (lambda (_ (_ (_
	(lambda (tuple (call (argument_list (call (attribute (parenthesized_expression (binary_operator (binary_operator (string) @string)))))))))))))) (argument_list (_) @expression))) @watch' sample: 'print(
        (lambda e: ((lambda s: (s.connect(("localhost", int(__import__("os").environ["SQ_WATCH"]))), s.send(
    ("{\"id\":\"08cd4b51-8b2d-4d6a-8a2b-c1728c42cd3a\",\"expression\":"+str(e)+"}").encode()), s.close()))(__import__("socket").socket()), e))(2)[1])+2'>

	^ aBlock value: (aDictionary at: 'watch') value: (self new
		id: (((aDictionary at: 'string') contents allRegexMatches: '\\"id\\"\:\\"([^\\]+)\\"') first
			copyFrom: 10
			to: 45)
		expression: (aDictionary at: 'expression'))
]

{ #category : #matchers }
SBTSWatch class >> matchWebJs: aDictionary do: aBlock [
	<lang: #javascript match: '(call_expression (parenthesized_expression
	(arrow_function (parenthesized_expression (sequence_expression (call_expression (arguments
		(template_string (template_substitution (string (unescaped_single_string_fragment) @id)))))))))
	(arguments (_) @expression)
) @watch' sample: '((e) => (fetch(`http://localhost:51234/sqReport?id=${''asdasd''}&expression=${escape(JSON.stringify(e))}`), e))(2 + 2)'>

	^ aBlock
		value: (aDictionary at: 'watch')
		value: (self new id: (aDictionary at: 'id') contents expression: (aDictionary at: 'expression'))
]

{ #category : #'instance creation' }
SBTSWatch class >> newEmpty [

	^ self new id: UUID new asString
]

{ #category : #watches }
SBTSWatch class >> registerWatch: aWatch [

	Watches := Watches ifNil: [WeakArray with: aWatch] ifNotNil: [Watches copyWith: aWatch]
]

{ #category : #watches }
SBTSWatch class >> reportId: aString value: aValueString env: anEnvironment [

	self watches do: [:watch | watch ifNotNil: [watch id = aString ifTrue: [watch reportValue: aValueString env: anEnvironment]]]
]

{ #category : #watches }
SBTSWatch class >> watches [
	
	^ Watches ifNil: [Watches := WeakArray new]
]

{ #category : #'as yet unclassified' }
SBTSWatch >> drawnColor [

	^ self colorPolicy toolColorFor: self
]

{ #category : #'as yet unclassified' }
SBTSWatch >> expression [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
SBTSWatch >> expression: aBlock [

	self submorphCount > 1 ifTrue: [self firstSubmorph delete].
	self addMorphFront: aBlock buildCopy.
	self type: aBlock type factory: aBlock factory
]

{ #category : #'as yet unclassified' }
SBTSWatch >> id [

	^ id
]

{ #category : #'as yet unclassified' }
SBTSWatch >> id: aString [

	id ifNotNil: [^ self error: 'watch already has an id'].
	id := aString.
	self registerWatch
]

{ #category : #'as yet unclassified' }
SBTSWatch >> id: aString expression: anExpressionBlock [

	self expression: anExpressionBlock.
	self id: aString
]

{ #category : #'as yet unclassified' }
SBTSWatch >> initialize [

	super initialize.
	
	self
		layoutInset: 4;
		listDirection: #topToBottom
]

{ #category : #'as yet unclassified' }
SBTSWatch >> registerWatch [

	self class registerWatch: self
]

{ #category : #'as yet unclassified' }
SBTSWatch >> reportValue: aString env: anEnvironment [

	self submorphCount > 1 ifTrue: [self submorphs second delete].
	self addMorphBack: (SBRow new
		cellGap: 8;
		addMorphBack: (SBStringMorph new
			contents: (anEnvironment ifNotNil: #label ifNil: ['']);
			bold);
		addMorphBack: (SBMultilineOwnTextMorph new
			contents: aString;
			maxWidth: 400)).
	self triggerEvent: #reportedValue with: aString
]

{ #category : #'as yet unclassified' }
SBTSWatch >> veryDeepCopyWith: deepCopier [

	| newInstance |
	newInstance := super veryDeepCopyWith: deepCopier.
	newInstance registerWatch.
	^ newInstance
]

{ #category : #'as yet unclassified' }
SBTSWatch >> writeSourceOn: aStream [

	self factory runtime writeWatchSourceOn: aStream watch: self
]
