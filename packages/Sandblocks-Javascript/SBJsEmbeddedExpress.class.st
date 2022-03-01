"
SBJsEmbeddedExpress is a visual replacement for routes in ExpressJS framework. It will replace patterns such a app.get(), app.get() with the UI defined in SBEmbeddedRequestTool.
"
Class {
	#name : #SBJsEmbeddedExpress,
	#superclass : #SBEmbeddedRequestTool,
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

	| url method morph |
	method := (aDictionary at: 'method') contents.
	url := (aDictionary at: 'url') childSandblocks first contents deepCopy.
	morph := (aDictionary at: 'methodBody') buildCopy.
	
	method
		caseOf: {
			['post'] -> [
				^ aBlock value: (aDictionary at: 'call_expression') 
					value:(SBJsEmbeddedExpressPost new
						factory: SBJavascript new;
						url: url headers: Dictionary new data: nil;
						sourceMorph: morph;
						addMorphBack: morph)].
			['get'] -> [
				^ aBlock value: (aDictionary at: 'call_expression') value: (SBJsEmbeddedExpressGet new
					factory: SBJavascript new;
					url: url headers: Dictionary new data: nil;
					sourceMorph: morph;
					addMorphBack: morph)]}
		otherwise: [^ nil]
]

{ #category : #'initialize-release' }
SBJsEmbeddedExpress >> recreateFromMorphs [
	super recreateFromMorphs.
	self addMorphBack: sourceMorph
]

{ #category : #'initialize-release' }
SBJsEmbeddedExpress >> recreateFromVariables: aHeaders params: aParams body: aBody [
	super recreateFromVariables: aHeaders params: aParams body: aBody.
	self addMorphBack: sourceMorph
]
