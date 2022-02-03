Class {
	#name : #SBPyEmbeddedRequests,
	#superclass : #SBEmbeddedRequestTool,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractBody: functionParameters [
	^functionParameters pairs.
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractHeaders: functionParameters [
	^functionParameters pairs.
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractMethod: aMethod [
	^aMethod contents
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> extractUrl: functionParameters [
	^functionParameters childSandblocks second childSandblocks first contents
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(expression_statement
	(call
    	function:(attribute object: 
        	(identifier) @requests
            attribute: (identifier) @method
            	) @function
    ) @function_parameter
) @ex'>

	| meth function_parameter url |
		
	function_parameter := ( aDictionary at: 'function_parameter').
	(self validate: function_parameter) ifFalse: [^nil].
	
	meth := self extractMethod: (aDictionary at: 'method').
	url := self extractUrl: function_parameter.
	
	meth
		caseOf: {
			['post'] -> [
				^ aBlock value: (aDictionary at: 'ex') 
					value:(SBPyEmbeddedRequestsPost new
						factory: SBJavascript new;
						url: url headers: Dictionary new data: '{}')].
			['get'] -> [
				^ aBlock value: (aDictionary at: 'ex') value: (SBPyEmbeddedRequestsGet new
					factory: SBJavascript new;
					url: url headers: Dictionary new data: nil)]}
		otherwise: [^ nil]
]

{ #category : #'as yet unclassified' }
SBPyEmbeddedRequests class >> validate: functionParameters [
	^functionParameters childSandblocks first childSandblocks first contents = 'requests'.  
]
