Class {
	#name : #SBMemoize2,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBMemoize2 class >> pythonFor: anExpressionString [

	^ (SBPython parseExpression: ('(lambda i, x, e: __import__("pickle").loads(__import__("pathlib").Path(i).read_bytes()) if __import__("os.path", fromlist=["isfile"]).isfile(i) else (lambda _r: (__import__("pathlib").Path(i).write_bytes(__import__("pickle").dumps(_r)), _r)[-1])(e()))("memoize", "{1}", lambda: {2})' format: {UUID new asString, '.pickle'. anExpressionString})) applyReplacement: self
]

{ #category : #'as yet unclassified' }
SBMemoize2 >> buildPython [
	<lang: #python match: '(call (parenthesized_expression (lambda)) (argument_list (string) ="memoize" (string) @id (lambda (_) @body)))' sample: '(lambda i, x, e: __import__(''pickle'').loads(__import__(''pathlib'').Path(i).read_bytes()) if __import__(''os.path'', fromlist=[''isfile'']).isfile(i) else (lambda _r: (__import__(''pathlib'').Path(i).write_bytes(__import__(''pickle'').dumps(_r)), _r)[-1])(e()))(''memoize'', ''a'', lambda: 3+4)'>

	self
		removeAllMorphs;
		layoutInset: 4 sbScaled;
		addMorphBack: (SBStringMorph new contents: 'Memoize: ');
		addMorphBack: (self createBindingBlock: 'body')
]

{ #category : #'as yet unclassified' }
SBMemoize2 >> drawnColor [

	^ Color veryDarkGray
]

{ #category : #'as yet unclassified' }
SBMemoize2 >> layoutCommands [

	^ SBAlgebraCommand container
		data: {(self submorphs at: 1) layoutCommands. SBAlgebraCommand gap. (self submorphs at: 2) layoutCommands};
		morph: self
]
