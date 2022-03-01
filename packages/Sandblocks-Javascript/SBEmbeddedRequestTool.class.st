"
SBEmbeddedRequestTool is a lean version of the SBRequestTool in terms of UI components. It represents the baseline for all visual abstractions for frameworks which either perform requests or resolve requests such as ExpressJS, JS Fetch API, Python Requests.
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
		registerShortcut: $h command do: #toggleHelp.
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> addBodySection: aBody [

	| tmpUrl |
	"Add the UI component for a body"
	self addMorphBack: SBRow new.
	bodyMorph := self submorphs fourth.
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
		
		
		].
"Future work: improve tmpUrl workaround"
(url startsWith: 'http://') ifFalse: [tmpUrl := baseUrl, url] ifTrue: [tmpUrl := url].

Examples at: tmpUrl, method ifPresent: [:examples | examples size > 0 ifTrue: [self addExampleSection]].
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> addExampleSection [
	"Add the UI component for displaying the examples."

	showExamples ifTrue: [ | map tmpUrl |
		self addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'Examples');
			addMorphBack: (SBRow new cellGap: cellGapConstant)).
		
		method caseOf: {
			[#get] -> [exampleMorph := self submorphs fourth].
			[#post] -> [exampleMorph := self submorphs sixth]}.
		
		"Future work: improve tmpUrl workaround"
		(url startsWith: 'http://')
			ifFalse: [tmpUrl := baseUrl, url]
			ifTrue: [tmpUrl := url].
		
		map := Examples at: tmpUrl, method asString ifAbsent: [].
		map ifNotNil: [map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]]]
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> addHeaderAction [
	"Add a new header."

	headerMorph submorphs size = 0 ifTrue: [headerMorph addMorphBack: (SBStringMorph new contents: 'Headers')].
	
	super addHeaderAction
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> addHeaderAction: key value: value [
"Add a new header with a given key and value."
	headerMorph submorphs size = 0 ifTrue: [headerMorph addMorphBack: (SBStringMorph new contents: 'Headers')].
	
	super addHeaderAction: key value: value
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> addParamAction [
"Add a new parameter"
	paramMorph submorphs size = 0 ifTrue: [paramMorph addMorphBack: (SBStringMorph new contents: 'Params')].
	
	super addParamAction
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> addParamAction: key value: value [

	(paramMorph submorphs size) = 0 ifTrue: [
		paramMorph
			addMorphBack: (SBStringMorph new contents: 'Params')].
		
	super addParamAction: key value: value.
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> addParamSection: aParams [

	"Add a new parameter with a given key and value."
	params keysDo: [:key | self addParamAction: ((params at: key) key) asString  value:  ((params at: key) value) asString].

	method = #get ifTrue: [ | tmpUrl |
		"Future work: improve tmpUrl workaround"
		tmpUrl := baseUrl, url, method.
		(url startsWith: 'http://') ifFalse: [tmpUrl := baseUrl, url, method] ifTrue: [tmpUrl := url, method].
	
		Examples at: tmpUrl
			ifPresent: [: e |
			e size > 0 ifTrue: [self addExampleSection]]].
]

{ #category : #'colors and color policies' }
SBEmbeddedRequestTool >> drawnColor [

	^ Color veryVeryLightGray.
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> hideExamplesButton [
	^(SBButton new icon: SBIcon iconEye shortcut: nil do: [
				showExamples := true.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self showExamplesButton.
				self recreateFromMorphs]; balloonText: 'Show Examples')
]

{ #category : #'initialize-release' }
SBEmbeddedRequestTool >> initCommons [
	"Setup shared UI elements"

	exploreResponse := false.
	sendButton := SBButton new
		icon: SBIcon iconPlay shortcut: nil do: [
			ActiveEvent shiftPressed
				ifTrue: [self sendAndExploreResponse]
				ifFalse: [self send]];
		balloonText: 'Send Request (Shift + Click to explore response)'.
	addDataButton := SBButton new
		color: (Color r: 0.0 g: 1 b: 0.0);
		icon: SBIcon iconPlus shortcut: nil do: [self promptAddPayload];
		balloonText: 'Add Data'.
	exampleButton := showExamples
		ifTrue: [self showExamplesButton]
		ifFalse: [self hideExamplesButton].
	self
		addMorphBack: (SBRow new
			changeTableLayout;
			hResizing: #spaceFill;
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: self urlLabel);
			addMorphBack: (SBTextBubble new
				hResizing: #spaceFill;
				contents: url);
			addMorphBack: sendButton;
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

{ #category : #'initialize-release' }
SBEmbeddedRequestTool >> initPost [
	self
		initCommons;
		addParamSection: nil.

	"Init the body section and add it"
	self	addMorphBack: SBRow new.
	bodyMorph := self submorphs fourth.
	self addBodySection: data
	
	
]

{ #category : #'initialize-release' }
SBEmbeddedRequestTool >> initialize [
	super initialize.
	showExamples := false.
	baseUrl := 'http://localhost:8080'
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> promptAddPayload [
"This will pop-up when the + Button is pressed. Depending on the HTTP method we can add different payload."

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

{ #category : #request }
SBEmbeddedRequestTool >> send [
	"Delegates to the correct request implementation."
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

{ #category : #request }
SBEmbeddedRequestTool >> sendAndExploreResponse [
	exploreResponse := true.
	self send.
	exploreResponse := false.

]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> showExamplesButton [
	^(SBButton new icon: SBIcon iconEyeSlash shortcut: nil do: [
				showExamples := false.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self hideExamplesButton.
				self recreateFromMorphs]; balloonText: 'Hide Examples')
]

{ #category : #accessing }
SBEmbeddedRequestTool >> sourceMorph [
	^ sourceMorph.
	
]

{ #category : #accessing }
SBEmbeddedRequestTool >> sourceMorph: aSourceMorph [
	sourceMorph := aSourceMorph.
	
]

{ #category : #'ui-manipulation' }
SBEmbeddedRequestTool >> toggleHelp [
	<action>
	"This will open all tooltips the help the user if he does not know the buttons."
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
]

{ #category : #synchronization }
SBEmbeddedRequestTool >> updateHeaders: aHeadersMorph [

	| key value index |
	"Loop through the headers morphs and update the headers map"
	index := 0.
	aHeadersMorph do: [:header |
		index := index + 1.
		index > 1 ifTrue: [
			key := header submorphs first contents.
			value := header submorphs second contents.
			key ~= nil & (key ~= '') ifTrue: [headers at: key put: value]]]
]

{ #category : #synchronization }
SBEmbeddedRequestTool >> updateParams: aParamsMorph [

	| key value index |
	"Loop through the params morphs and update the param map"
	index := 0.
	aParamsMorph do: [:paramMorph |
		index := index + 1.
		index > 1 ifTrue: [
			key := paramMorph submorphs first contents.
			value := paramMorph submorphs second contents.
			key ~= nil & (key ~= '') ifTrue: [params at: key, value put: key -> value]]]
]

{ #category : #accessing }
SBEmbeddedRequestTool >> urlLabel [
"Label for the embedded UI"
	method caseOf: {
	[#post] -> [^ 'POST'].
	[#get] -> [^ 'GET']}
	
]

{ #category : #accessing }
SBEmbeddedRequestTool >> values [
	method caseOf: {
	[#post] -> [^ #(Header Param Body)].
	[#get] -> [^ #(Header Param)]}
	
]
