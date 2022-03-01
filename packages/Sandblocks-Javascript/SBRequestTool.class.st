"
Standalone Request Tool. This appears in the JS Palette and can be placed via Drag & Drop next to the source code to perform requests. It allows to build requests via a UI. Headers, Parameter, and Body can be added and the HTTP method can be switched. 
"
Class {
	#name : #SBRequestTool,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'url',
		'method',
		'headers',
		'cellGapConstant',
		'data',
		'isRawData',
		'params',
		'paramMorph',
		'headerMorph',
		'urlMorph',
		'bodyMorph',
		'methodMorph',
		'exampleMorph',
		'exploreResponse',
		'maxNumberOfExamples'
	],
	#classVars : [
		'Examples'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'ui-manipulation' }
SBRequestTool >> addBodySection: aBody [

	| key |
	"Add the UI component for a body"
	aBody ifNotNil: [
		"isRawData is explained in the Setter of the variable itself"
		isRawData
			ifFalse: [
				bodyMorph
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SBButton new icon: SBIcon iconPlus label: 'Field' do: [self addFieldAction]);
					addMorphBack: (SBRow new
						cellGap: cellGapConstant;
						addMorphBack: (SBRow new
							cellGap: 0;
							addMorphBack: (SBRequestToolFieldTextBubble new
								cellGap: 0;
								placeholderText: 'key');
							addMorphBack: (SBTextBubble new
								cellGap: 0;
								placeholderText: 'value')))]
			ifTrue: [
				bodyMorph
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SBRequestToolBodyTextBubble new contents: aBody)].
		
		key := url, method asString.
		Examples at: key ifPresent: [:examples | examples size > 0 ifTrue: [self addExampleSection]]]
]

{ #category : #'ui-manipulation' }
SBRequestTool >> addExampleSection [
	"Add the UI component for displaying the examples."
	| map |
		self addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'Examples');
			addMorphBack: (SBRow new cellGap: cellGapConstant)).
		
		method = #post ifTrue: [exampleMorph := self submorphs eighth].
		method = #get ifTrue: [exampleMorph := self submorphs seventh].
		map := Examples at: url, method asString ifAbsent: [].
		map ifNotNil: [map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]].
]

{ #category : #'ui-manipulation' }
SBRequestTool >> addFieldAction [
"Add field parameter for post requests with no raw data."
	self submorphs sixth
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBRequestToolFieldTextBubble new
				placeholderText: 'key');
			addMorphBack: (SBTextBubble new
				placeholderText: 'value');
			cellGap: 0);
		cellGap: cellGapConstant.
]

{ #category : #'ui-manipulation' }
SBRequestTool >> addHeaderAction [
"Add a new header."
	headerMorph
		addMorphBack: (SBRow new
			addMorphBack: (SBRequestToolHeaderTextBubble new
				placeholderText: 'key');
			addMorphBack: (SBTextBubble new
				placeholderText: 'value');
			cellGap: 0);
		cellGap: cellGapConstant.
]

{ #category : #'ui-manipulation' }
SBRequestTool >> addHeaderAction: key value: value [
"Add a new header with a given key and value."
	| valueTextBubble |
	valueTextBubble := value = '' ifTrue: [(SBTextBubble new placeholderText: 'value')] ifFalse: [(SBTextBubble new contents: value)].
	
	headerMorph
		addMorphBack: (SBRow new
			addMorphBack: (SBRequestToolHeaderTextBubble new
				contents: key);
			addMorphBack: valueTextBubble;
			 cellGap: 0);
		cellGap: cellGapConstant.
		
	value = '' ifTrue: [].
]

{ #category : #'ui-manipulation' }
SBRequestTool >> addParamAction [
"Add a new parameter"
	paramMorph
		submorphs;
		addMorphBack: (SBRow new
			addMorphBack: (SBRequestToolParamTextBubble new
				placeholderText: 'key');
			addMorphBack: (SBTextBubble new
				placeholderText: 'value');
			cellGap: 0);
		cellGap: cellGapConstant.

]

{ #category : #'ui-manipulation' }
SBRequestTool >> addParamAction: key value: value [
"Add a new parameter with a given key and value."
	paramMorph
		submorphs;
		addMorphBack: (SBRow new
			addMorphBack: (SBRequestToolParamTextBubble new
				contents: key);
			addMorphBack: (SBTextBubble new
				contents: value);
			cellGap: 0);
		cellGap: cellGapConstant.
]

{ #category : #'ui-manipulation' }
SBRequestTool >> addParamSection: aParams [
"Add the UI component to display parameters."
	| s |
	self
		addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'Params');
			addMorphBack: (SBButton new icon: SBIcon iconPlusCircle label: 'Param' do: [self addParamAction]));
		addMorphBack: (SBRow new
			cellGap: cellGapConstant).
	
	paramMorph := self submorphs sixth.
	params keysDo: [:key | self addParamAction: ((params at: key) key) asString  value:  ((params at: key) value) asString].

	method = #get ifTrue: [
		s := url, method.
		Examples at: s
			ifPresent: [: e |
			e size > 0 ifTrue: [self addExampleSection]]].
]

{ #category : #'ui-manipulation' }
SBRequestTool >> addRequestToExampleMap: response [
"Add the response to the example map. Call this after send."
	| map example |
	map := Examples at: url, method asString ifAbsent: [nil].
	example := nil.
	
	"Create the example"
	method caseOf: {
		[#get] -> [
			example := SBRequestToolGetExample new
				icon: SBIcon iconSearch
				label: response code asString
				do: [example promptChangeValue].
			example
				code: response code deepCopy
				url: url deepCopy
				headers: headers deepCopy
				params: params deepCopy].
		[#post] -> [
			example := SBRequestToolPostExample new
				icon: SBIcon iconSearch
				label: response code asString
				do: [example promptChangeValue].
			example
				code: response code
				url: url deepCopy
				headers: headers deepCopy
				body: data deepCopy
				params: params deepCopy]}.
	
	"Add the example to the existing map or into a new map"
	map ifNotNil: [ | examplesForUrl |
		examplesForUrl := Examples at: url, method asString.
		examplesForUrl at: response code ifAbsentPut: [OrderedCollection new].
		(examplesForUrl at: response code) size < maxNumberOfExamples ifFalse: [(examplesForUrl at: response code) removeLast].
		(examplesForUrl at: response code) add: example beforeIndex: 1].
	map ifNil: [ | initDict initColl |
		initDict := Dictionary new.
		initColl := OrderedCollection new.
		initColl add: example.
		initDict at: response code put: initColl.
		Examples at: url, method asString put: initDict]
]

{ #category : #accessing }
SBRequestTool >> body [
	^ data
]

{ #category : #accessing }
SBRequestTool >> body: aBody [
	data := aBody
]

{ #category : #accessing }
SBRequestTool >> bodyMorph: aBodyMorph [
	bodyMorph := aBodyMorph
]

{ #category : #'initialize-release' }
SBRequestTool >> clearPanel [
	(1 to: self submorphs size) do: [:n| | morph |
		morph := self submorphs at: 1.
		morph abandon].
]

{ #category : #'initialize-release' }
SBRequestTool >> collectParamsString [

	| paramString init |
	"Loop through the params and put them into a single string"
	paramString := String new.
	init := true.
	params keysDo: [:key || value |
		value := (params at: key) value.
		key ~= '' ifTrue: [ | paramText |
			paramText := ((params at: key) key) withBlanksTrimmed, '=', value withBlanksTrimmed.
			init ifTrue: [
					paramString := paramString, '?'.
					paramString := paramString, paramText.
					init := false]
				ifFalse: [paramString := paramString, '&', paramText]]].

	^ paramString
]

{ #category : #accessing }
SBRequestTool >> data: body [
	data := body.
]

{ #category : #accessing }
SBRequestTool >> examples [
	^Examples.
]

{ #category : #accessing }
SBRequestTool >> headerMorph [
	^headerMorph.
]

{ #category : #accessing }
SBRequestTool >> headers [
	^headers
]

{ #category : #accessing }
SBRequestTool >> headers: aHeadersMap [
	headers := aHeadersMap.
]

{ #category : #'initialize-release' }
SBRequestTool >> initCommons [
	"Setup UI elements which are shared accross different HTTP methods."

	self
		addMorphBack: (SBRow new
			changeTableLayout;
			hResizing: #spaceFill;
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'URL: ');
			addMorphBack: (SBTextBubble new
				hResizing: #spaceFill;
				contents: url);
			addMorphBack: (SBButton new icon: SBIcon iconPlusCircle label: 'Send' do: [self send]));
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'Method');
			addMorphBack: (SBRequestToolMethodSelect new object: method));
		addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'Headers');
			addMorphBack: (SBButton new
				color: (Color r: 0.0 g: 1 b: 0.0);
				icon: SBIcon iconPlusCircle label: 'Header' do: [self addHeaderAction]));
		addMorphBack: SBRow new.
	
	"Set the the morphs centrally for easier acces"
	urlMorph := self submorphs first.
	methodMorph := self submorphs second submorphs second.
	headerMorph :=  self submorphs fourth.
	
	headers ifNotNil: [headers keysDo: [:key | self addHeaderAction: key asString value: (headers at: key) asString]].
]

{ #category : #'initialize-release' }
SBRequestTool >> initGet [
"Initializes the UI for GET requests."
	self
		initCommons;
		addParamSection: nil.
]

{ #category : #'initialize-release' }
SBRequestTool >> initPost [
"Initializes the UI for POST requests."
	self
		initCommons;
		addParamSection: nil.

	"Init the body section and add it"
	self	addMorphBack: SBRow new.
	bodyMorph := self submorphs seventh.
	data ifNotNil: [self addBodySection: data].
	data ifNil: [self addBodySection: '']
	
	
	
]

{ #category : #accessing }
SBRequestTool >> isRawData: aBoolean [
"isRawData describes the body of a POST request. 
If it is true the body can be JSON, Text, HTML, XML, ...
If isRawData is set to false the body can be e.g. form-data (key value pairs), binary, GraphQL, etc..."

"Example CURL POST with no raw data:"
"curl --location --request POST 'http://localhost:8080/user' \
--header 'Content-Type: application/json' \
--form 'key='value'"

"Example CURL POST with raw data:"
"curl --location --request POST 'http://localhost:8080/user' \
--header 'Content-Type: application/json' \
--data-raw '{
    'id': 1,
    'username': 'Theo'
}'"


	isRawData := aBoolean.
]

{ #category : #accessing }
SBRequestTool >> method [
	^method.
]

{ #category : #accessing }
SBRequestTool >> method: aMethod [
	method := aMethod.
]

{ #category : #accessing }
SBRequestTool >> params [
	^params
]

{ #category : #accessing }
SBRequestTool >> params: aParams [
	params := aParams.
]

{ #category : #request }
SBRequestTool >> performGetRequest: urlWithParams [

	| resp client response |
	"Perform a GET request in Smalltalk"
	client := WebClient new.
	resp := client
		httpGet: urlWithParams
		do: [:req | headers keysDo: [:key | req headerAt: key put: (headers at: key)]].
	
	response := resp content.
	
	self addRequestToExampleMap: resp.
	
	[exploreResponse ifTrue: [(Json readFrom: response readStream) explore]]
		on: Error
		do: [(Json readFrom: '{"Error":"Only JSON response can be explored. Check your Transcript to see the response."}' readStream) explore].
	
	Transcript
		show: response asString;
		cr.
	self recreateFromMorphs
]

{ #category : #request }
SBRequestTool >> performPostRequest: body url: aUrl [
	"Perform a POST request in Smalltalk"
	| resp client response tmpHeaders |
	client := WebClient new.
	"Deep copy the headers so that I can set a default for Content-Type"
	tmpHeaders := headers deepCopy.
	resp := client
		httpPost: url
		content: (body ifNil: [''])
		type: (tmpHeaders at: 'Content-Type' ifAbsent: 'application/json')
		do: [:req |
			tmpHeaders removeKey: 'Content-Type' ifAbsent: [].
			tmpHeaders keysDo: [:key | req headerAt: key put: (tmpHeaders at: key)]].
	
	response := resp content.
	
	self addRequestToExampleMap: resp.
	
	[exploreResponse ifTrue: [(Json readFrom: response readStream) explore]]
		on: Error
		do: [(Json readFrom: '{"Error":"Only JSON response can be explored. Check your Transcript to see the response."}' readStream) explore].
	
	Transcript
		show: response asString;
		cr.
	
	self recreateFromMorphs.
]

{ #category : #'initialize-release' }
SBRequestTool >> recreateFromMorphs [
"Recreate the UI based on the currently filled form"
	self updatePayloadInObjectInstance.
	self clearPanel.
	method = #get ifTrue: [self initGet].
	method = #post ifTrue: [self initPost]
]

{ #category : #'initialize-release' }
SBRequestTool >> recreateFromVariables: aHeaders params: aParams body: aBody [
"Recreate the UI based on the given input. Used when recreating for Examples."
	params := aParams.
	headers := aHeaders.
	data := aBody.
	self clearPanel.
	method = #get ifTrue: [self initGet].
	method = #post ifTrue: [self initPost]
]

{ #category : #request }
SBRequestTool >> send [
	"Send delegates to the correct method to do the actual request."
	| paramsString |
	self updatePayloadInObjectInstance.
	paramsString := self collectParamsString.
	
	method = #get ifTrue: [self performGetRequest: url asString, paramsString].
	method = #post ifTrue: [
		isRawData 
			ifTrue: [self performPostRequest: data url: url asString, paramsString]
			ifFalse: [self flag: #todo "Implement this for the case of a POST request with form data as body. (edge case which is not covered in this prototype at the moment)"].
	
	self flag: #todo "implement other methods here"]
]

{ #category : #accessing }
SBRequestTool >> updateBody: body [
	data := body contents
	
]

{ #category : #synchronization }
SBRequestTool >> updateHeaders: aHeadersMorph [
"Loop through the headers morphs and update the headers map"
	| key value |
	aHeadersMorph do: [: header |
		key := header submorphs first contents.
		value := header submorphs second contents.
		(key ~= nil and: [(key ~= '')]) ifTrue: [headers at: key put: value]]
]

{ #category : #synchronization }
SBRequestTool >> updateParams: aParamsMorph [
"Loop through the params morphs and update the param map"
	| key value |
	aParamsMorph do: [:paramMorph | 
		key := paramMorph submorphs first contents.
		value := paramMorph submorphs second contents.
		(key ~= nil) & (key ~= '') ifTrue: [params at: (key, value) put: (key -> value)]]
]

{ #category : #synchronization }
SBRequestTool >> updatePayloadInObjectInstance [
"Update the class variables (headers, params, url, body...) based on the current form"
	self updateHeaders: headerMorph submorphs.
	self updateParams: paramMorph submorphs.
	url := (urlMorph submorphs second) contents.

	method = #post ifTrue: [ isRawData ifTrue: [
			bodyMorph ifNotNil:[
				bodyMorph submorphs size > 1 ifTrue: [
					self updateBody: (bodyMorph submorphs second)]]]]
]

{ #category : #'initialize-release' }
SBRequestTool >> url: aString method: aMethod headers: aHeaders data: aData [
	"Constructs a SBRequestTool"

	"maxNumberOfExamples sets the maximum of examples which will be stored per endpoint and response code."
	"e.g.,  5 examples for http://localhost:8080/user with response code 200"
	maxNumberOfExamples := 5.
	url := aString.
	headers := aHeaders.
	data := aData.
	method := aMethod.
	cellGapConstant := 3.
	"isRawData is explained in the Setter of the variable itself"
	isRawData := true.
	Examples ifNil: [Examples := Dictionary new].
	"Use the next line delete the existing examples."
	"Examples := Dictionary new."
	params := Dictionary new.
	exploreResponse := true.
	
	method = #get ifTrue: [self initGet].
	method = #post ifTrue: [self initPost].
	self flag: #todo. "implement other methods (put, trace, etc.)"
]

{ #category : #'initialize-release' }
SBRequestTool >> writeSourceOn: aStream [ 
	self subclassResponsibility.
]
