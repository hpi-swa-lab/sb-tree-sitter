Class {
	#name : #SBJsPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsPalette class >> buildOn: aBuilder [

	aBuilder addHeader: 'IVU'.
	
	aBuilder addSectionHeader: 'Tracks'.
	aBuilder addBlock: 'get rail tracks' as: (SBJavascript parseExpression: 'IVU.railGetTracks()').
	aBuilder
		addBlock: 'get rail tracks'
		as: (SBJavascript parseExpression: 'IVU.railGetTrackCapacity()').
	aBuilder
		addBlock: 'geo filter'
		as: (SBJavascript parseWithPlaceholders: 'IVU.GeoFilter(_latlng, _radius)')
]

{ #category : #'as yet unclassified' }
SBJsPalette class >> language [

	^ SBJavascript
]
