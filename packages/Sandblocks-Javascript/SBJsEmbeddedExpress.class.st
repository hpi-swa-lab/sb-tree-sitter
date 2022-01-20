"
Base class to replace in JavaScript source code fetch calls.
"
Class {
	#name : #SBJsEmbeddedExpress,
	#superclass : #SBJsEmbeddedRequestTool,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpress class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '
(call_expression
	(member_expression
    	(identifier) 
        (property_identifier) @method) @member
    (arguments
    	(string) @url
        (arrow_function) @methodBody)
) @call_expression'>

	| url method |
	method := (aDictionary at: 'method') contents.
	url := (aDictionary at: 'url') childSandblocks first contents deepCopy.
	
	method
		caseOf: {
			['post'] -> [
				^ aBlock value: (aDictionary at: 'call_expression') 
					value:(SBJsEmbeddedExpressPost new
						factory: SBJavascript new;
						url: url headers: Dictionary new data: nil;
						source: (SBJavascript parse: ((aDictionary at: 'methodBody') sourceString));
						addMorphBack: (SBJavascript parse: ((aDictionary at: 'methodBody') sourceString)))].
			['get'] -> [
				^ aBlock value: (aDictionary at: 'call_expression') value: (SBJsEmbeddedExpressGet new
					factory: SBJavascript new;
					url: url headers: Dictionary new data: nil;
					source: (SBJavascript parse: ((aDictionary at: 'methodBody') sourceString));
					addMorphBack: (SBJavascript parse: ((aDictionary at: 'methodBody') sourceString)))]}
		otherwise: [^ nil]
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpress >> promptAddPayload [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpress >> recreateFromMorphs [
	super recreateFromMorphs.
	self addMorphBack: (SBJavascript parse: ((sourceString) sourceString))
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpress >> values [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedExpress >> writeSourceOn: aStream [ 
	| prefix |
	"Transforms into JS source code"
	prefix := ''.
	
	method caseOf: {
		[#get] -> [prefix := 'app.get("'].
		[#post] -> [prefix := 'app.post("'].
	}.
	"self halt."
	aStream nextPutAll: prefix.
	aStream nextPutAll: url asString, '"', ','.
	aStream nextPutAll: (self source) sourceString.
	aStream nextPutAll:  ')'.
]
