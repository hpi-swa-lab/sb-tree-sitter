Class {
	#name : #SBJsEmbeddedFetch,
	#superclass : #SBJsEmbeddedRequestTool,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetch class >> extractBody: aBody [
	^aBody childSandblocks first contents

]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetch class >> extractHeaders: aHeaders [
	^aHeaders pairs.
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetch class >> extractMethod: aMethod [
	
	^aMethod childSandblocks first contents
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetch class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '
(call_expression
    (identifier) 
    (arguments
    	(string) @url
        (object)) @params
) @call_expression'>

	| params method body headers url |
	
	params := (aDictionary at: 'params') childSandblocks second childSandblocks.
	(1 to: params  size) do: [:n|| key value|
		key := (params at: n) childSandblocks first contents ifNil: [(params at: n) childSandblocks first childSandblocks first contents].
		value := (params at: n) childSandblocks second.
		key caseOf: {
			['method'] -> [method := SBJsEmbeddedFetch extractMethod: value].
			['body'] -> [body := SBJsEmbeddedFetch extractBody: value].
			['headers'] -> [headers := SBJsEmbeddedFetch extractHeaders: value]
		} otherwise: nil.
		].
	url := (aDictionary at: 'url') childSandblocks first contents.
	method
		caseOf: {
			['POST'] -> [
				^ aBlock value: (aDictionary at: 'call_expression') 
					value:(SBJsEmbeddedFetchPost new
						factory: SBJavascript new;
						url: url headers: headers data: body;
						source: nil)].
			['GET'] -> [
				^ aBlock value: (aDictionary at: 'call_expression') value: (SBJsEmbeddedFetchGet new
					factory: SBJavascript new;
					url: url headers: headers data: nil;
					source: nil)]}
		otherwise: [^ nil]
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetch >> headersToWritableString [
	| txt |
	txt := ''.
	headers keysDo: [:key| txt := txt, '''', key asString, '''',  ':','''', (headers at: key) asString, '''', ','].
	^txt copyFrom: 1 to: (txt size) - 1
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetch >> promptAddPayload [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedFetch >> writeSourceOn: aStream [ 
	self subclassResponsibility.
]