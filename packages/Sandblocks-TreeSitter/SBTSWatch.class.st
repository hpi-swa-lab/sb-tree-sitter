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

{ #category : #'as yet unclassified' }
SBTSWatch class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(call_expression (member_expression
	(call_expression (member_expression
		(call_expression (identifier) ="require" (arguments (string (unescaped_double_string_fragment) ="net")))
		(property_identifier) ="connect"))
	(property_identifier) ="end")
	(arguments
		(call_expression (arguments (object
			(pair (property_identifier) ="id" (string (unescaped_double_string_fragment) @id))
			(pair (property_identifier) ="expression" (_) @expression)))))) @watch' sample: 'require("net").connect("/home/tom/tmp/server.sock").end(JSON.stringify({id:"asda", expression:value}))'>

	^ aBlock
		value: (aDictionary at: 'watch')
		value: (self new id: (aDictionary at: 'id') expression: (aDictionary at: 'expression'))
]

{ #category : #'as yet unclassified' }
SBTSWatch class >> registerWatch: aWatch [

	Watches := Watches ifNil: [WeakArray with: aWatch] ifNotNil: [Watches copyWith: aWatch]
]

{ #category : #'as yet unclassified' }
SBTSWatch class >> reportId: aString value: aJsonObject [

	self watches do: [:watch | watch ifNotNil: [watch id = aString ifTrue: [watch reportValue: aJsonObject]]]
]

{ #category : #'as yet unclassified' }
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
SBTSWatch >> id [

	^ id
]

{ #category : #'as yet unclassified' }
SBTSWatch >> id: aStringBlock expression: anExpressionBlock [

	id := aStringBlock contents.
	self addMorphBack: anExpressionBlock buildCopy.
	self registerWatch
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
SBTSWatch >> reportValue: aJsonObject [

	self submorphCount > 1 ifTrue: [self submorphs second delete].
	self addMorphBack: (SBMultilineOwnTextMorph new
		contents: aJsonObject printString;
		maxWidth: 400)
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
