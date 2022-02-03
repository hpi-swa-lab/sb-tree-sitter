"
Base class which replaces source code with a tool to perform HTTP requests.
"
Class {
	#name : #SBEmbeddedRequestTool,
	#superclass : #SBRequestTool,
	#instVars : [
		'showExamples',
		'showExamplesButtonTxt',
		'sourceMorph',
		'sendButton',
		'addDataButton',
		'exampleButton',
		'baseUrl'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool class >> matchJs: aDictionary do: aBlock [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool class >> matchPython: aDictionary do: aBlock [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool class >> registerShortcuts: aProvider [

	aProvider
		registerShortcut: $h command do: #toggleHelp
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> addBodySection: aBody [

	| tmpUrl |
	self addMorphBack: SBRow new.
	bodyMorph := self submorphs fourth.
	aBody ifNotNil: [
		isRawData
			ifFalse: [
				bodyMorph
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SBButton new icon: SBIcon iconPlus label: 'Field' do: [self addFieldAction]);
					addMorphBack: (SBRow new
						cellGap: cellGapConstant;
						addMorphBack: (SBRow new
							cellGap: 0;
							addMorphBack: (SBJsRequestToolFieldTextBubble new
								cellGap: 0;
								placeholderText: 'key');
							addMorphBack: (SBTextBubble new
								cellGap: 0;
								placeholderText: 'value')))]
			ifTrue: [
				bodyMorph
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SBJsRequestToolBodyTextBubble new contents: aBody)].
		
		
		].
"TODO, improve tmpUrl workaround"
(url startsWith: 'http://') ifFalse: [tmpUrl := baseUrl, url] ifTrue: [tmpUrl := url].

Examples at: tmpUrl, method ifPresent: [:examples | examples size > 0 ifTrue: [self addExampleSection]].
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> addExampleSection [
	
	showExamples ifTrue: [
		 | map tmpUrl |
		
			self addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Examples');
				addMorphBack: (SBRow new cellGap: cellGapConstant)).
				
			exampleMorph := self submorphs fourth.
			"TODO, improve tmpUrl workaround"
			(url startsWith: 'http://') ifFalse: [tmpUrl := baseUrl, url] ifTrue: [tmpUrl := url].
			
			map := Examples at: tmpUrl, method asString ifAbsent: [].
			map ifNotNil: [ map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]]]
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> addHeaderAction [
	(headerMorph submorphs size) = 0 ifTrue: [
		headerMorph
			addMorphBack: (SBStringMorph new contents: 'Headers')].
		
	super addHeaderAction.
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> addHeaderAction: key value: value [

	(headerMorph submorphs size) = 0 ifTrue: [
			headerMorph
				addMorphBack: (SBStringMorph new contents: 'Headers')].
			
	super addHeaderAction: key value: value.
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> addParamAction [

	(paramMorph submorphs size) = 0 ifTrue: [
		paramMorph
			addMorphBack: (SBStringMorph new contents: 'Params')].
		
	super addParamAction.

]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> addParamAction: key value: value [

	(paramMorph submorphs size) = 0 ifTrue: [
		paramMorph
			addMorphBack: (SBStringMorph new contents: 'Params')].
		
	super addParamAction: key value: value.
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> addParamSection: aParams [

	
	params keysDo: [:key | self addParamAction: ((params at: key) key) asString  value:  ((params at: key) value) asString].
	
	"Whats have I done here :)"
	SBToggledCode comment: '' active: 0 do: {
		[
			params keysDo: [:key | | k v |
				k := (params at: key) submorphs first.
				v := (params at: key) submorphs second.
				self addParamAction: k contents value: v contents]]}.

	method = #get ifTrue: [ | tmpUrl |
		"TODO, improve tmpUrl workaround"
		tmpUrl := baseUrl, url, method.
		(url startsWith: 'http://') ifFalse: [tmpUrl := baseUrl, url, method] ifTrue: [tmpUrl := url, method].
	
		Examples at: tmpUrl
			ifPresent: [: e |
			e size > 0 ifTrue: [self addExampleSection]]].
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> drawnColor [

	^ Color veryVeryLightGray.
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> exploreResponse [
   <action>

   self halt.
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> hideExamplesButton [
	^(SBButton new icon: SBIcon iconEye shortcut: nil do: [
				showExamples := true.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self showExamplesButton.
				self recreateFromMorphs]; balloonText: 'Show Examples')
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> initCommons [
	"Setup shared UI elements"
	sendButton :=  (SBButton new icon: SBIcon iconPlay shortcut: nil do: [self send]; balloonText: 'Send Request').
	addDataButton :=  (SBButton new
				color: (Color r: 0.0 g: 1 b: 0.0);
				icon: SBIcon iconPlus shortcut: nil do: [self promptAddPayload]; balloonText: 'Add Data').
	exampleButton := (showExamples ifTrue: [self showExamplesButton] ifFalse: [self hideExamplesButton]).
	self
		addMorphBack: (SBRow new
			changeTableLayout;
			hResizing: #spaceFill;
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: self urlLabel);
			addMorphBack: (SBTextBubble new
				hResizing: #spaceFill;
				contents: url);
			addMorphBack:sendButton;
			addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: addDataButton;
			addMorphBack: exampleButton));
		listDirection: #topToBottom;
		addMorphBack: SBRow new;
		addMorphBack: SBRow new.
			
	
	"Initialize the the morphs centrally for easier acces"
	urlMorph := self submorphs first.
	headerMorph := self submorphs second.
	paramMorph := self submorphs third.
	
	headers ifNotNil: [headers keysDo: [:key | self addHeaderAction: key asString value: (headers at: key) asString]]
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> initPost [
	self
		initCommons;
		addParamSection: nil.

	"Init the body section and add it"
	self	addMorphBack: SBRow new.
	bodyMorph := self submorphs fourth.
	self addBodySection: data
	
	
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> initialize [
	super initialize.
	showExamples := false.
	baseUrl := 'http://localhost:8080'
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> promptAddPayload [

	| fetch index |
	fetch := self owner owner owner.
	index := UIManager default chooseFrom: self values.
	
	method caseOf: {
		[#post] -> [
			index > 0 ifTrue: [
				index caseOf: {
					[1] -> [self addHeaderAction].
					[2] -> [self addParamAction].
					[3] -> [self addBodySection: '{}']}]].
		[#get] -> [
			index > 0 ifTrue: [
				index caseOf: {
					[1] -> [self addHeaderAction].
					[2] -> [self addParamAction]}]]}
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> send [

	| paramsString |
	
	self updatePayloadInObjectInstance.
	paramsString := self collectParamsString.
	(url startsWith: 'http://') ifFalse: [url := baseUrl, url].
	

	method = #get ifTrue: [self performGetRequest: url asString, paramsString].
	method = #post ifTrue: [
		isRawData 
			ifTrue: [self performPostRequest: data url: url asString, paramsString]
			ifFalse: ["TODO: collect fields and perform request"]
	
	"TODO: implement other methods"]
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> showExamplesButton [
	^(SBButton new icon: SBIcon iconEyeSlash shortcut: nil do: [
				showExamples := false.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self hideExamplesButton.
				self recreateFromMorphs]; balloonText: 'Hide Examples')
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> sourceMorph [
	^ sourceMorph.
	
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> sourceMorph: aSourceMorph [
	sourceMorph := aSourceMorph.
	
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> toggleHelp [
	<action>
	
	| dataPosition examplePosition sendPosition downConstant |
	downConstant := 10.
	
	"Move data balloon down a bit and to the right."
	sendPosition := sendButton positionInWorld.
	sendPosition setX: (sendPosition x)  setY: (sendPosition y).
	
	"Move data balloon down a bit and to the right."
	dataPosition := addDataButton positionInWorld.
	dataPosition setX: (dataPosition x) + 20 setY: (dataPosition y) + downConstant.
	
	"Move example balloon up a bit."
	examplePosition := exampleButton positionInWorld.
	examplePosition setX: (examplePosition x) + 20 setY: (examplePosition y) +( downConstant * 3).

	sendButton showBalloon: sendButton balloonText at: sendPosition.
	addDataButton showBalloon: addDataButton balloonText at: dataPosition.
	exampleButton showBalloon: exampleButton balloonText at:  examplePosition.
	
     "sendButton deleteBalloon."
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> updateHeaders: aHeadersMorph [
"Loop through the headers morphs and update the headers map"
	| key value index |
	index := 0.
	aHeadersMorph do: [: header |
		index := index + 1.
		index > 1 ifTrue: [
		key := header submorphs first contents.
		value := header submorphs second contents.
		key ~= nil & (key ~= '') ifTrue: [headers at: key put: value]]]
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> updateParams: aParamsMorph [
"Loop through the params morphs and update the param map"
	| key value index |
	index := 0.
	aParamsMorph do: [:paramMorph | 
		index := index + 1.
		index > 1 ifTrue: [
		key := paramMorph submorphs first contents.
		value := paramMorph submorphs second contents.
		(key ~= nil) & (key ~= '') ifTrue: [params at: (key, value) put: (key -> value)]]]
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> urlLabel [
	method caseOf: {
	[#post] -> [^ 'POST'].
	[#get] -> [^ 'GET']}
	
]

{ #category : #'as yet unclassified' }
SBEmbeddedRequestTool >> values [
	method caseOf: {
	[#post] -> [^ #(Header Param Body)].
	[#get] -> [^ #(Header Param)]}
	
]
