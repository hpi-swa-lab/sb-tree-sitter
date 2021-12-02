Class {
	#name : #SBJsFetch,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'url',
		'method',
		'headers',
		'cellGapConstant',
		'data',
		'isRawData'
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
) @call'>

	(aDictionary at: 'fetch') contents = 'fetch' ifFalse: [^ nil].
	(aDictionary at: 'window') contents = 'window' ifFalse: [^ nil].
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new url: (aDictionary at: 'url') childSandblocks first contents options: (aDictionary at: 'params'))
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
	"self recreate: method."
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addHeaderAction [
	
	self submorphs fourth
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBJsFetchHeaderTextBubble new
				placeholderText: 'key');
			addMorphBack: (SBTextBubble new
				placeholderText: 'value');
			cellGap: 0);
		cellGap: cellGapConstant.
	"self recreate: method."
]

{ #category : #'as yet unclassified' }
SBJsFetch >> addHeaderAction: key value: value [

	| valueTextBubble |
	valueTextBubble := value = '' ifTrue: [(SBTextBubble new placeholderText: 'value')] ifFalse: [(SBTextBubble new contents: value)].
	
	self submorphs fourth
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
	self submorphs sixth
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
SBJsFetch >> clearPanel [
	(1 to: self submorphs size) do: [:n| | morph |
		morph := self submorphs at: 1.
		morph abandon].
]

{ #category : #'as yet unclassified' }
SBJsFetch >> collectParamsString: params [

	| paramString |
	"Loop through the params and put them into a single string"
	paramString := ''.
	
	(1 to: params size) do: [:n | | paramText key value |
		key := (params at: n) submorphs first contents.
		value := (params at: n) submorphs second contents.
		key ~= '' ifTrue: [
		paramText := key withBlanksTrimmed, '=', value withBlanksTrimmed.
		n = 1
			ifTrue: [
				paramString := paramString asString, '?'.
				paramString := paramString, paramText]
			ifFalse: [paramString := paramString asString, '&', paramText]]].
	
	^ paramString
]

{ #category : #'as yet unclassified' }
SBJsFetch >> data: body [
	data := body.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> headers [
	^headers
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
			addMorphBack: (SimpleButtonMorph new
				target: self;
				label: 'Send';
				color: (Color r: 1 g: 0.879 b: 0.0);
				borderWidth: 1;
				borderRaised;
				actionSelector: #send));
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'Method');
			addMorphBack: (SBJsFetchMethodSelect new object: method));
		addMorphBack:  (SBRow new
		cellGap: cellGapConstant;
		addMorphBack: (SBStringMorph new contents: 'Headers');
		"This SBButton crashes everything"
		"addMorphBack: (SBButton new label: '+ Header');"
		addMorphBack: (SimpleButtonMorph new
			target: self;
			label: '+ Header';
			color: (Color r: 1 g: 0.879 b: 0.0);
			borderWidth: 1;
			borderRaised;
			actionSelector: #addHeaderAction));
		addMorphBack: (SBRow new).
		
		headers keysDo: [:key | self addHeaderAction: key asString value: (headers at: key) asString].
		
]

{ #category : #'as yet unclassified' }
SBJsFetch >> initGet: aParams [
	
	self initCommons
		addMorphBack: (SBRow new
		cellGap: cellGapConstant;
		addMorphBack: (SBStringMorph new contents: 'Params');
		addMorphBack: (SimpleButtonMorph new
			target: self;
			label: '+ Param';
			color: (Color r: 1 g: 0.879 b: 0.0);
			borderWidth: 1;
			borderRaised;
			actionSelector: #addParamAction));
		addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBRow new
				cellGap: 0;
				addMorphBack: (SBJsFetchParamTextBubble new
					cellGap: 0;
					placeholderText: 'key');
				addMorphBack: (SBTextBubble new
					cellGap: 0;
					placeholderText: 'value'))).
]

{ #category : #'as yet unclassified' }
SBJsFetch >> initPost: aBody [

	isRawData
		ifFalse: [
			self initCommons
				addMorphBack: (SBRow new
					cellGap: cellGapConstant;
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SimpleButtonMorph new
						target: self;
						label: '+ Field';
						color: (Color r: 1 g: 0.879 b: 0.0);
						borderWidth: 1;
						borderRaised;
						actionSelector: #addFieldAction));
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
			self initCommons addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Body');
				addMorphBack: (SBJsFetchBodyTextBubble new contents: aBody))]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> isRawData: bool [
	isRawData := bool.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> method [
	^method.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> method: aMethod [
	method := aMethod.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> performGetRequest: url headers: headers [

	| resp client response |
	client := WebClient new.
	resp := client
		httpGet: url
		do: [:req | headers keysDo: [:key | req headerAt: key put: (headers at: key)]].

	response := resp content.
	"resp code = 200 ifTrue: [ | responseBody |responseBody := resp content]."
	Transcript show: response asString; cr.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> performPostRequest: url headers: headers body: body [

	| resp client response |
	client := WebClient new.
	resp := client
		httpPost: url content: body type: (headers at: 'Content-Type' ifAbsent: 'application/json') do: [:req |
			headers removeKey: 'Content-Type' ifAbsent: [].
			headers keysDo: [:key | req headerAt: key put: (headers at: key)]].

	response := resp content.
	"resp code = 200 ifTrue: [ | responseBody |responseBody := resp content]."
	Transcript show: response asString; cr.
]

{ #category : #'as yet unclassified' }
SBJsFetch >> recreate: aMethod [
	| aUrl |
	aUrl := self submorphs first submorphs second contents.
	self updateHeaderMap:  self submorphs fourth submorphs.
	aMethod = #get ifTrue: [
		"TODO: params does not get saved on recreate"
		self clearPanel.
		method := #get.
		url := aUrl.
		self initGet: data
		].
	aMethod = #post ifTrue: [
		self updateHeaderMap:  self submorphs fourth submorphs.
		self clearPanel.
		method := #post.
		"isRawData := true."
		url := aUrl.
		self initPost: data].
]

{ #category : #'as yet unclassified' }
SBJsFetch >> send [

	| aUrl aMethod |
	"Prepare data and perform request"
	self updateHeaderMap: self submorphs fourth submorphs.
	aUrl := self submorphs first submorphs second contents.
	aMethod := self submorphs second submorphs second contents.
	"self halt."
	aMethod = 'GET' ifTrue: [ | paramsString |
		paramsString := self collectParamsString: self submorphs sixth submorphs.
		self performGetRequest: aUrl asString, paramsString headers: headers].
	aMethod = 'POST' ifTrue: [
		isRawData
			ifTrue: [self performPostRequest: aUrl headers: headers body: self submorphs fifth submorphs second contents]
			ifFalse: ["TODO: collect fields and perform request"]
		"TODO: implement other methods"]
]

{ #category : #'as yet unclassified' }
SBJsFetch >> updateHeaderMap: aHeaders [
	| headerCount key value |
	"Loop through the headers morphs and update the headers map"
	
	headerCount := aHeaders size.
	(1 to: headerCount) do: [:n | 
		key := (aHeaders at: n) submorphs first contents.
		value := (aHeaders at: n) submorphs second contents.
		key ~= nil & (key ~= '') ifTrue: [headers at: key put: value].
		].
]

{ #category : #'initialize-release' }
SBJsFetch >> url: aString method: aMethod headers: headersMap data: aData [
	"Make common fields class fields"
	"Constructs a SBJsFetch object"

	url := aString.
	method := aMethod.
	headers := headersMap.
	cellGapConstant := 7.
	data := aData.
	"Use this variable to indicate if body in POST is of type raw. TODO: might be improved"
	isRawData := true.
	
	aMethod = #post ifTrue: [self initPost: aData].
	aMethod = #get ifTrue: [self initGet: aData]
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
