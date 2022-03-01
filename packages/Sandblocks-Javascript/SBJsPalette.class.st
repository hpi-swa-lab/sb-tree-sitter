Class {
	#name : #SBJsPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsPalette class >> buildOn: aBuilder [

	aBuilder addHeader: 'Javascript'.
	
	aBuilder addSectionHeader: 'Fetch'.
	
	aBuilder addBlock: 'POST' as: (SBRequestTool new
		factory: SBJavascript new;
		url: 'http://localhost:8080'
			method: #post
			headers: (Dictionary newFrom: {'Content-Type' -> 'application/json'})
			data: '{"key" : "value"}').
			
	aBuilder addBlock: 'GET' as: (SBRequestTool new
		factory: SBJavascript new;
		url: 'http://localhost:8080/'
			method: #get
			headers: (Dictionary newFrom: {'Content-Type' -> 'text/html'})
			data: '{"key" : "value"}').
]

{ #category : #'as yet unclassified' }
SBJsPalette class >> language [

	^ #javascript
]
