"
A custom replacement for the 'dashes=x' keyword argument. The value of the argument is sequence, a tuple of numbers. When clicked, a popup opens that shows the sequence entries as rows.
"
Class {
	#name : #SBPyPltDashes,
	#superclass : #SBPyPltParamCustomReplace,
	#instVars : [
		'image',
		'dialogBody',
		'popup'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltDashes class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="dashes"
      value: (tuple) @value
) @argument' sample: 'dashes=(3,2,1,1)'>
" add alternation"

	| integers |
	integers := ((aDictionary at: 'value') childSandblocks collect: [:each | each contents]) asOrderedCollection.
	
	integers size odd ifTrue: [integers add: '0'].
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementFromSequence: integers
			)
]

{ #category : #'insert/delete' }
SBPyPltDashes >> addRow [

	self addRowWithDashLength: '2' spaceRight: '1'.
	self update.
]

{ #category : #'insert/delete' }
SBPyPltDashes >> addRowWithDashLength: aString1 spaceRight: aString2 [

	| row |
	row := SBRow new
				addMorphBack: (SBPyNumberWithPrefix new prefix: 'dash length'; contents: aString1; rangeFrom: 0 to: 100;
					when: #edited send: #update to: self);
				addMorphBack: (SBPyNumberWithPrefix new prefix: 'space right:'; contents: aString2; rangeFrom: 0 to: 100;
					when: #edited send: #update to: self).
	
	row addMorphBack:
					(IconicButton new
						color: Color red muchLighter;
						borderColor: Color red;
						labelGraphic: MenuIcons smallDeleteIcon;
						target: self;
						actionSelector: #delete:;
						arguments: {row};
						yourself
					).
	
	dialogBody addMorph: row atIndex: (dialogBody submorphCount - 1).
]

{ #category : #'initialize-release' }
SBPyPltDashes >> createReplacementFromSequence: aCollection [

	| button |
	
	self initRowsFromSequence: aCollection.
	
	button := SBTextBubble new prefix: 'dashes='; contents: self sequence; when: #doubleClicked send: #openPopup to: self.
	self addMorphBack:  button.
]

{ #category : #'insert/delete' }
SBPyPltDashes >> delete: aSBRow [
	dialogBody removeMorph: aSBRow.
	self update.
]

{ #category : #accessing }
SBPyPltDashes >> info [

	^ 'Set the dash sequence.

The dash sequence is a sequence of floats of even length describing the length of dashes and spaces in points.

For example, (5, 2, 1, 2) describes a sequence of 5 point and 1 point dashes separated by 2 point spaces.

'
]

{ #category : #'initialize-release' }
SBPyPltDashes >> initRowsFromSequence: aCollection [
"aCollection is a collection of stringified integers"

	(1 to: aCollection size by: 2) do: [ :anInt |
			self addRowWithDashLength: (aCollection at: anInt) spaceRight: (aCollection at: (anInt + 1))
		].
	
	self update.
]

{ #category : #'initialize-release' }
SBPyPltDashes >> initialize [

	super initialize.
	
	dialogBody := (SBColumn new 
			addMorphBack: (TextMorph new contents: (self info); hResizing: #rigid; width: 200; centered; margins: 2);
			addMorphBack: (SBButton new
				icon: SBIcon iconPlus label: 'Add' do: [self addRow]
			);
			addMorphBack: (image ifNil: ['' asMorph] ifNotNil: image)
		).
	popup := SBPopup new addMorphBack: dialogBody.
]

{ #category : #updating }
SBPyPltDashes >> openPopup [
	| firstTimeOpened |
	popup showBelow: self closeOnDeselect: true.
	
	firstTimeOpened := popup firstSubmorph lastSubmorph class = StringMorph.
	firstTimeOpened ifTrue: [self update].
]

{ #category : #accessing }
SBPyPltDashes >> sequence [
"returns the the string of the sequence, e.g. '(1, 2, 3, 6)'"

	| seqValues |
	seqValues := self sequenceValues.
	
	(seqValues size = 0) ifTrue: [^ '' ].
	(seqValues size = 1) ifTrue: [^ (seqValues at: 1)].
	
	^'(',((2 to: seqValues size) inject: (seqValues at: 1) into: [:acc :i | acc,', ',(seqValues at: i)]),')'
]

{ #category : #accessing }
SBPyPltDashes >> sequenceValues [
"returns the values of the sequence, i.e a collection of strings like {'1'. '3'}"

	^ (dialogBody submorphs 
		select: [:each | each class = SBRow] 
		thenCollect: [:aRow | {(aRow submorphs at: 1) textContents.  (aRow submorphs at: 2) textContents}])
		gather: [:aCollection | aCollection].
]

{ #category : #updating }
SBPyPltDashes >> update [
	popup isInWorld ifFalse: [^ self].

	super update.
	self updateImage.
	self updateReplacementBtn.
]

{ #category : #updating }
SBPyPltDashes >> updateImage [
	image := (Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: (SBPython instance runtime evaluate: '
import matplotlib.pyplot as plt
import io
import base64
import sys

X1 = [1, 1, 1]

fig, ax = plt.subplots()

# set fig height to 100 pixels
fig.set_figheight(1)
fig.set_figwidth(2)

ax.plot(X1, dashes=(',self sequence,'))
ax.axis("off")


bytes = io.BytesIO()
plt.savefig(bytes, format="png")
bytes.seek(0)
sys.stdout.buffer.write(base64.b64encode(bytes.read()))
bytes.close()
') readStream)) asMorph.

	dialogBody removeMorph: (dialogBody submorphs last).
	dialogBody addMorphBack: image.
]

{ #category : #updating }
SBPyPltDashes >> updateReplacementBtn [

	(self submorphs size = 0) ifTrue: [^nil].
	self firstSubmorph firstSubmorph contents: self sequence.
]

{ #category : #copying }
SBPyPltDashes >> writeSourceOn: aStream [

	| prefix |
	prefix := self firstSubmorph prefix.
	
	aStream nextPutAll: (prefix,self sequence).
]
