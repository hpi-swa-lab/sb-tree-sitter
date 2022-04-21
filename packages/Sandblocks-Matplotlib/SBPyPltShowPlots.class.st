"
This replacements shows the image by executing its enclosing module.
"
Class {
	#name : #SBPyPltShowPlots,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'image'
	],
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'event handling' }
SBPyPltShowPlots >> artefactSaved: anArtefact [
	anArtefact = self containingArtefact ifTrue: [self updateImage].
]

{ #category : #'initialize-release' }
SBPyPltShowPlots >> build [
	<lang: #python match: '(call
	function: (attribute
		(identifier) ="plt"
        (identifier) ="show"
    )
)' sample: 'plt.show()'>

	image := '' asMorph.
	self addMorphBack: (SBColumn new
		addMorphBack: (SBButton new icon: SBIcon iconPlay label: 'show plot' do: [self updateImage]);
		addMorphBack: image asMorph)
]

{ #category : #accessing }
SBPyPltShowPlots >> palettes [

	^ {SBPyPltPaletteOverview}
]

{ #category : #'event handling' }
SBPyPltShowPlots >> updateImage [

	| program form |
	program := self toplevel.
	form := (Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: ([program evaluate] on: Error do: [:err |
		^ self firstSubmorph lastSubmorph replaceBy: (SBMultilineOwnTextMorph new
			contents: err contents;
			maxWidth: 400;
			yourself)]) readStream)) trimBordersOfColor: (Color r: 1 g: 1 b: 1).
	image := form asMorph.
	self firstSubmorph lastSubmorph replaceBy: image
]

{ #category : #printing }
SBPyPltShowPlots >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	aStream nextPutAll: '(lambda b:(fig.set_dpi(60),fig.set_size_inches(3,3),plt.savefig(b, format="png"),b.seek(0),__import__("sys").stdout.buffer.write(__import__("base64").b64encode(b.read())),b.close()))(__import__("io").BytesIO())'
]
