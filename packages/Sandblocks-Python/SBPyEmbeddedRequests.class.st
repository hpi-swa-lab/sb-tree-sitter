"
Base class to replace calls from Pythons requests package.
"
Class {
	#name : #SBPyEmbeddedRequests,
	#superclass : #SBEmbeddedRequestTool,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractBody: arguments [

	| bodyString |
	bodyString := String new.
	(1 to: arguments childSandblocks size) do: [:i | | parameter |
		parameter := (arguments childSandblocks at: i) childSandblocks.
		parameter size > 1 ifTrue: [ | parameterIdentifier |
			parameterIdentifier := parameter first contents.
			parameterIdentifier = 'json' ifTrue: [ | dict |
				dict := parameter second childSandblocks.
				(1 to: dict size) do: [:n | | key value |
					key := (dict at: n) childSandblocks first contents.
					value := (dict at: n) childSandblocks second contents.
					n = 1 ifTrue: [bodyString := bodyString, '{'].
					bodyString := bodyString, '"', key asString, '"', ':', '"', value asString, '"', ',']]]].
	bodyString = '' ifTrue: [^ nil] ifFalse: [
		bodyString := bodyString copyFrom: 1 to: bodyString size - 1.
		bodyString := bodyString, '}'.
		^ bodyString]
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractHeaders: arguments [

	| headersMap |
	headersMap := Dictionary new.
	(1 to: arguments childSandblocks size) do: [:i | | parameter |
		parameter := (arguments childSandblocks at: i) childSandblocks.
		parameter size > 1 ifTrue: [ | parameterIdentifier |
			parameterIdentifier := parameter first contents.
			parameterIdentifier = 'headers' ifTrue: [ | dict |
				dict := parameter second childSandblocks.
				(1 to: dict size) do: [:n | | key value |
					key := (dict at: n) childSandblocks first contents.
					value := (dict at: n) childSandblocks second contents.
					headersMap at: key asString put: value asString]]]].
	^ headersMap
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractMethod: aMethod [
	^aMethod contents
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractUrl: arguments [
	^arguments childSandblocks first contents
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '	(call
    	function:(attribute object: 
        	(identifier) @requests
            attribute: (identifier) @method)
         arguments: (argument_list) @arguments
    ) @call'>

	| meth url body header arguments |
	arguments := ( aDictionary at: 'arguments').
	(self validate:  ( aDictionary at: 'requests')) ifFalse: [^nil].
	
	meth := self extractMethod: (aDictionary at: 'method').
	url := self extractUrl: arguments.
	header := self extractHeaders: arguments.
	body := self extractBody: arguments.
	"self halt."
	meth
		caseOf: {
			['post'] -> [
				^ aBlock value: (aDictionary at: 'call') 
					value:(SBPyEmbeddedRequestsPost new
						factory: SBJavascript new;
						url: url headers: header data: body)].
			['get'] -> [
				^ aBlock value: (aDictionary at: 'call') value: (SBPyEmbeddedRequestsGet new
					factory: SBJavascript new;
					url: url headers: header data: nil)]}
		otherwise: [^ nil]
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> validate: requests [
	^requests contents = 'requests'.  
]
