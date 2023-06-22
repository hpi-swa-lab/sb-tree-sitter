Class {
	#name : #SBFormRequest,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Typescript'
}

{ #category : #'as yet unclassified' }
SBFormRequest >> build [
	<lang: #typescript match: '(call_expression
      function: (member_expression
		(identifier) ="app"
 		(property_identifier) ="post"
      )
	arguments: (arguments (string (_) @path) (_ (statement_block) @body))
)' sample: 'app.post("/post", function (req, res) {req.body})'>

	| column |
	column := SBColumn new
		addMorphBack: (self
			createStatic: [:c |
				SBStringMorph new
					contents: 'Post', (c copyReplaceAll: '/' with: ' ');
					bold]
			contents: 'path');
		cellGap: 4 sbScaled.
	
	(((bindings at: 'body') queryAll: '(member_expression (member_expression (identifier) ="req" (property_identifier) ="body") (property_identifier) @param)') collect: #contents) withoutDuplicates do: [:field |
		column addMorphBack: (SBStringMorph new contents: field capitalized).
		column addMorphBack: (SBTextBubble new
			minimumWidth: 300;
			setProperty: #fieldName toValue: field;
			placeholderText: ('Enter {1} ...' format: {field}))].
	
	column addMorphBack: (SBButton new label: 'Submit' do: [self send]).
	
	self
		addMorphBack: column;
		layoutInset: 8 sbScaled
]

{ #category : #'as yet unclassified' }
SBFormRequest >> send [

	| body |
	body := (self firstSubmorph submorphs select: [:c | c hasProperty: #fieldName])
		collect: [:c | (c valueOfProperty: #fieldName) -> c contents]
		as: Dictionary.
	
	WebClient
		httpPost: 'http://localhost:3000', (bindings at: 'path') contents
		content: body asJsonString
		type: 'application/json'
]
