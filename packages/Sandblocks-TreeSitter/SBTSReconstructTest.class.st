Class {
	#name : #SBTSReconstructTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSReconstructTest >> randomBlockIn: aBlock [

	^ (Array streamContents: [:array | aBlock allBlocksDo: [:b | (b sourceStringForCompare size between: 1 and: 20) ifTrue: [array nextPut: b]]]) atRandom
]

{ #category : #'as yet unclassified' }
SBTSReconstructTest >> testJavascript [

	| program source editor |
	program := SBJavascript parseToplevel: 'const express = require(''express'');
const app = express();
const http = require(''http'');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);

app.get(''/'', (req, res) => {
  res.sendFile(__dirname + ''/index.html'');
});

io.on(''connection'', (socket) => {
  console.log(''a user connected'');
});

server.listen(3000, () => {
  console.log(''listening on *:3000'');
});
'.
	editor := self editorAndWorldFor: program.
	source := program sourceStringForCompare.
	
	10 timesRepeat: [ | target targetSourceString |
		target := self randomBlockIn: program.
		targetSourceString := target sourceString.
		target changeToUnknown.
		self type: targetSourceString in: editor.
		editor
			allBlocksDetect: [:b | b isKindOf: SBTSInputReconcile]
			ifFound: [:x |
				self tick.
				self tick.
				editor handle: (self keyboardEvent: Character cr)]
			ifNone: [].
		self assert: source equals: program sourceStringForCompare]
]
