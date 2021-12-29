Class {
	#name : #SBJsFetch,
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
		'exampleThreshold'
	],
	#classVars : [
		'Examples'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetch class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(call_expression
	(member_expression
    	(identifier) @window
        (property_identifier) @fetch)
    (arguments
    	(string) @url
        (object) @params)
) @call' sample: 'window.fetch(''url'', {})'>

	(aDictionary at: 'fetch') contents = 'fetch' ifFalse: [^ nil].
	(aDictionary at: 'window') contents = 'window' ifFalse: [^ nil].
	
	^ aBlock value: (aDictionary at: 'call') value: (self new
		url: (aDictionary at: 'url') childSandblocks first contents
		options: (aDictionary at: 'params'))
]

{ #category : #'as yet unclassified' }
SBJsFetch >> Examples [
	^Examples.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addBodySection: aBody [

	| key |
	isRawData
		ifFalse: [
			self
				addMorphBack: (SBRow new
					cellGap: cellGapConstant;
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SBButton new icon: SBIcon iconPlus label: 'Field' do: [self addFieldAction]));
				addMorphBack: (SBRow new
					cellGap: cellGapConstant;
					addMorphBack: (SBRow new
						cellGap: 0;
						addMorphBack: (SBJsFetchFieldTextBubble new
							cellGap: 0;
							placeholderText: 'key');
						addMorphBack: (SBTextBubble new
							cellGap: 0;
							placeholderText: 'value')))]
		ifTrue: [
			self addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Body');
				addMorphBack: (SBJsFetchBodyTextBubble new contents: aBody))].
	
	bodyMorph := self submorphs seventh.
	
	key := url, (method asString).
	Examples at: key ifPresent: [:examples | examples size > 0 ifTrue: [self addExampleSection]]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addExampleSection [

	SBToggledCode comment: '' active: 1 do: {
		[ | map |
			self addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Examples');
				addMorphBack: (SBRow new cellGap: cellGapConstant)).
				
			method = #post ifTrue: [exampleMorph := self submorphs eighth].
			method = #get ifTrue: [exampleMorph := self submorphs seventh].
			map := Examples at: url, method asString ifAbsent: [].
			map ifNotNil: [ map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]]].
		}
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addFieldAction [
	self submorphs sixth
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBJsFetchFieldTextBubble new
				placeholderText: 'key');
			addMorphBack: (SBTextBubble new
				placeholderText: 'value');
			cellGap: 0);
		cellGap: cellGapConstant.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addHeaderAction [
	headerMorph
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBJsFetchHeaderTextBubble new
				placeholderText: 'key');
			addMorphBack: (SBTextBubble new
				placeholderText: 'value');
			cellGap: 0);
		cellGap: cellGapConstant.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addHeaderAction: key value: value [

	| valueTextBubble |
	valueTextBubble := value = '' ifTrue: [(SBTextBubble new placeholderText: 'value')] ifFalse: [(SBTextBubble new contents: value)].
	
	headerMorph
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBJsFetchHeaderTextBubble new
				contents: key);
			addMorphBack: valueTextBubble;
			 cellGap: 0);
		cellGap: cellGapConstant.
		
	value = '' ifTrue: [].
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addParamAction [
	paramMorph
		submorphs;
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBJsFetchParamTextBubble new
				placeholderText: 'key');
			addMorphBack: (SBTextBubble new
				placeholderText: 'value');
			cellGap: 0);
		cellGap: cellGapConstant.

]

{ #category : #'as yet unclassified' }
SBJsFetch >> addParamAction: key value: value [
	self submorphs sixth
		submorphs;
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBJsFetchParamTextBubble new
				contents: key);
			addMorphBack: (SBTextBubble new
				contents: value);
			cellGap: 0);
		cellGap: cellGapConstant.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addParamSection: aParams [

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
	
	"TODO: revisit"
	SBToggledCode comment: '' active: 0 do: {
		[
			params keysDo: [:key | | k v |
				k := (params at: key) submorphs first.
				v := (params at: key) submorphs second.
				self addParamAction: k contents value: v contents]]}.

	method = #get ifTrue: [
		s := url, method.
		Examples at: s
			ifPresent: [: e |
			e size > 0 ifTrue: [self addExampleSection]]].
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addRequestToExampleMap: response [

	| map example |
	map := Examples at: url, method asString ifAbsent: [nil].
	example := nil.
	
	"Create the example"
	method caseOf: {
		[#get] -> [
			example := SBJsFetchGetExample new
				icon: SBIcon iconSearch
				label: response code asString
				do: [example promptChangeValue].
			example
				code: response code deepCopy
				url: url deepCopy
				headers: headers deepCopy
				params: params deepCopy].
		[#post] -> [
			example := SBJsFetchPostExample new
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
		(examplesForUrl at: response code) size < exampleThreshold ifFalse: [(examplesForUrl at: response code) removeLast].
		(examplesForUrl at: response code) add: example beforeIndex: 1].
	map ifNil: [ | initDict initColl |
		initDict := Dictionary new.
		initColl := OrderedCollection new.
		initColl add: example.
		initDict at: response code put: initColl.
		Examples at: url, method asString put: initDict]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> body [
	^ data
]

{ #category : #'as yet unclassified' }
SBJsFetch >> body: aBody [
	data := aBody
]

{ #category : #'as yet unclassified' }
SBJsFetch >> bodyMorph: aBodyMorph [
	bodyMorph := aBodyMorph
]

{ #category : #'as yet unclassified' }
SBJsFetch >> clearPanel [
	(1 to: self submorphs size) do: [:n| | morph |
		morph := self submorphs at: 1.
		morph abandon].
]

{ #category : #'as yet unclassified' }
SBJsFetch >> collectParamsString [

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

{ #category : #'as yet unclassified' }
SBJsFetch >> data: body [
	data := body.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> headerMorph [
	^headerMorph.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> headers [
	^headers
]

{ #category : #'as yet unclassified' }
SBJsFetch >> headers: aHeadersMap [
	headers := aHeadersMap.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> initCommons [
	"Setup shared UI elements"

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
			addMorphBack: (SBJsFetchMethodSelect new object: method));
		addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'Headers');
			addMorphBack: (SBButton new
				color: (Color r: 0.0 g: 1 b: 0.0);
				icon: SBIcon iconPlusCircle label: 'Header' do: [self addHeaderAction]));
		addMorphBack: SBRow new.
	
		"Initialize the the morphs centrally for easier acces"
	urlMorph := self submorphs first.
	methodMorph := self submorphs second submorphs second.
	headerMorph :=  self submorphs fourth.
	
	headers ifNotNil: [headers keysDo: [:key | self addHeaderAction: key asString value: (headers at: key) asString]].
]

{ #category : #'initialize-release' }
SBJsFetch >> initGet [
	self
		initCommons;
		addParamSection: nil.
]

{ #category : #'initialize-release' }
SBJsFetch >> initPost [
	self
		initCommons;
		addParamSection: nil.
	
	data ifNotNil: [self addBodySection: data]
	
	
]

{ #category : #'as yet unclassified' }
SBJsFetch >> isRawData: aBoolean [
	isRawData := aBoolean.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> method [
"Get the method of the class instance"
	^method.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> method: aMethod [
"Set the method of the class instance"
	method := aMethod.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> params [
"Get the params map of the class instance"
	^params
]

{ #category : #'as yet unclassified' }
SBJsFetch >> params: aParams [
"Set the params map of the class instance"
	params := aParams.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> performGetRequest: urlWithParams [

	| resp client response |
	client := WebClient new.
	resp := client
		httpGet: urlWithParams
		do: [:req | headers keysDo: [:key | req headerAt: key put: (headers at: key)]].
	
	response := resp content.
	
	self addRequestToExampleMap: resp.
	
	Transcript
		show: response asString;
		cr.
	self recreateFromMorphs.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> performPostRequest: body url: aUrl [

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
	
	Transcript
		show: response asString;
		cr.
	self recreateFromMorphs.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> recreateFromMorphs [
"Recreate the UI based on the currently filled form"

	self updatePayloadInObjectInstance.
	self clearPanel.
	method = #get ifTrue: [self initGet].
	method = #post ifTrue: [self initPost]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> recreateFromVariables: aHeaders params: aParams body: aBody [
"Recreate the UI based on the given input. Used when recreating for Examples."
	params := aParams.
	headers := aHeaders.
	data := aBody.
	self clearPanel.
	method = #get ifTrue: [self initGet].
	method = #post ifTrue: [self initPost]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> send [

	| paramsString |
	self updatePayloadInObjectInstance.
	paramsString := self collectParamsString.

	method = #get ifTrue: [self performGetRequest: url asString, paramsString].
	method = #post ifTrue: [
		isRawData 
			ifTrue: [self performPostRequest: data url: url asString, paramsString]
			ifFalse: ["TODO: collect fields and perform request"]
	
	"TODO: implement other methods"]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> updateBody: body [
	data := body contents
	
]

{ #category : #'as yet unclassified' }
SBJsFetch >> updateHeaders: aHeadersMorph [
"Loop through the headers morphs and update the headers map"
	| key value |
	aHeadersMorph do: [: header |
		key := header submorphs first contents.
		value := header submorphs second contents.
		key ~= nil & (key ~= '') ifTrue: [headers at: key put: value]]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> updateParams: aParamsMorph [
"Loop through the params morphs and update the param map"
	| key value |
	aParamsMorph do: [:paramMorph | 
		key := paramMorph submorphs first contents.
		value := paramMorph submorphs second contents.
		(key ~= nil) & (key ~= '') ifTrue: [params at: (key, value) put: (key -> value)]]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> updatePayloadInObjectInstance [
"Update the class variables (headers, params, url, body...) based on the current form"
	self updateHeaders: headerMorph submorphs.
	self updateParams: paramMorph submorphs.
	url := (urlMorph submorphs second) contents.
	method = #post ifTrue: [ isRawData ifTrue: [bodyMorph ifNotNil: [self updateBody: (bodyMorph submorphs second)]]]
]

{ #category : #'initialize-release' }
SBJsFetch >> url: aString method: aMethod headers: aHeaders data: aData [
	"Constructs a SBJsFetch object"

	"exampleThreshold sets the maximum of examples per request and response code."
	exampleThreshold := 5.
	url := aString.
	method := aMethod.
	headers := aHeaders.
	cellGapConstant := 7.
	data := aData.
	"isRawData indicates if body in POST is of type raw. TODO: might be improved"
	isRawData := true.
	Examples ifNil: [Examples := Dictionary new].
	"Examples := Dictionary new."
	params := Dictionary new.
	
	aMethod = #post ifTrue: [self initPost].
	aMethod = #get ifTrue: [self initGet]
	"TODO: implement other methods (put, trace, delete...)"
]

{ #category : #'initialize-release' }
SBJsFetch >> url: aString options: aSBInlineBlockSymbol [ 
	self
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'URL: ');
			addMorphBack: (SBTextBubble new contents: aString));
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'Params ');
			addMorphBack: (SBStringMorph new contents: aSBInlineBlockSymbol sourceString));
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'Header ');
			addMorphBack: (SBTextBubble new contents: aSBInlineBlockSymbol sourceString))
]

{ #category : #'as yet unclassified' }
SBJsFetch >> writeSourceOn: aStream [ 
	"Transforms into JS source code"
	
	aStream nextPutAll: 'window.fetch("'.
	aStream nextPutAll: self firstSubmorph submorphs second contents.
	aStream nextPutAll: '", '.
	aStream nextPutAll: self submorphs second submorphs second contents.
	aStream nextPutAll: ')'.
]
