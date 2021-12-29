Class {
	#name : #SBJsPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsPalette class >> buildOn: aBuilder [

	aBuilder addHeader: 'Javascript'.
	
	aBuilder addSectionHeader: 'Fetch'.
	aBuilder addBlock: 'simple fetch' as: (SBJavascript parse: 'window.fetch("")').
	aBuilder
		addBlock: 'json fetch'
		as: (SBJavascript parse: 'window.fetch("", {headers: {"Content-Type": "application/json"}})').
	aBuilder addBlock: 'json fetch' as: (SBJsFetch new
		factory: SBJavascript new;
		url: 'http://...'
			options: (SBJavascript parse: '{headers: {"Content-Type": "application/json"}}') childSandblocks first).
	aBuilder addBlock: 'GET' as: (SBJsFetch new
		factory: SBJavascript new;
		url: 'http://localhost:8080'
			method: #get
			headers: (Dictionary newFrom: {'Content-Type' -> 'text/html'})
			data: '{"key" : "value"}').
	
	aBuilder addBlock: 'POST' as: (SBJsFetch new
		factory: SBJavascript new;
		url: 'http://localhost:8080'
			method: #post
			headers: (Dictionary newFrom: {'Content-Type' -> 'application/json'})
			data: '{"key" : "value"}').
			
	aBuilder addBlock: 'GET' as: (SBJsFetch new
		factory: SBJavascript new;
		url: 'http://localhost:8080/user'
			method: #get
			headers: (Dictionary newFrom: {'Content-Type' -> 'text/html'})
			data: '{"key" : "value"}').
			
	aBuilder addBlock: 'Small GET' as: (SBJsFetchSmallGet new
		factory: SBJavascript new;
			url: 'http://localhost:8080/user'
			headers: (Dictionary newFrom: {'Content-Type' -> 'text/plain'})
			data: nil).
			
	aBuilder addBlock: 'Small POST' as: (SBJsFetchSmallPost new
		factory: SBJavascript new;
			url: 'http://localhost:8080/example'
			headers: (Dictionary newFrom: {'Content-Type' -> 'text/plain'})
			data: '{"key" : "value"}').
]

{ #category : #'as yet unclassified' }
SBJsPalette class >> language [

	^ #javascript
]
