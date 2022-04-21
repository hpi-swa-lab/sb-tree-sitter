Class {
	#name : #SBPyPltEnumSelect,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltEnumSelect >> build [
	<lang: #python match: '(keyword_argument name: (identifier) @name value: (string (string_content) @value))' sample: 'ax.plot(abc="asd")'>

	| capStyles joinStyles |
	joinStyles := {
		{
			'miter'.
			SBPyPltImage joinStyleMiter.
			'the "arrow-tip" style. Each boundary of the filled-in area will extend in a straight line parallel to the tangent vector of the centerline at the point it meets the corner, until they meet in a sharp point.'}.
		{
			'round'.
			SBPyPltImage joinStyleRound.
			'stokes every point within a radius of linewidth/2 of the center lines.'}.
		{
			'bevel'.
			SBPyPltImage joinStyleBevel.
			'the "squared-off" style. It can be thought of as a rounded corner where the "circular" part of the corner has been cut off.'}}.
	capStyles := {
		{
			'projecting'.
			SBPyPltImage capStyleProjecting.
			'the line is squared off as in butt, but the filled in area extends beyond the endpoint a distance of linewidth/2.'}.
		{'butt'. SBPyPltImage capStyleButt. 'the line is squared off at its endpoint.'}.
		{
			'round'.
			SBPyPltImage capStyleRound.
			'like butt, but a semicircular cap is added to the end of the line, of radius linewidth/2.'}}.
	{
		'dash_capstyle' -> capStyles.
		'solid_capstyle' -> capStyles.
		'drawstyle' -> {
			{'default'. SBPyPltImage drawstyleDefault. 'For "default", the points are connected with straight lines.'}.
			{
				'steps'.
				SBPyPltImage drawstylePre.
				'"steps" is equal to "steps-pre" and is maintained for backward-compatibility.'}.
			{
				'steps-pre'.
				SBPyPltImage drawstylePre.
				'The step is at the beginning of the line segment, i.e. the line will be at the y-value of point to the right.'}.
			{'steps-mid'. SBPyPltImage drawstyleMid. 'The step is halfway between the points.'}.
			{
				'steps-post'.
				SBPyPltImage drawstylePost.
				'The step is at the end of the line segment, i.e. the line will be at the y-value of the point to the left.'}}.
		'solid_joinstyle' -> joinStyles.
		'dash_joinstyle' -> joinStyles.
		'marker' -> {
			{'.'. SBPyPltImage point. 'point'}.
			{'o'. SBPyPltImage circle. 'circle'}.
			{'^'. SBPyPltImage triangleUp. 'triangleUp'}.
			{'s'. SBPyPltImage square. 'square'}.
			{'+'. SBPyPltImage plus. 'plus'}.
			{'1'. SBPyPltImage triDown. 'tri_down'}.
			{'|'. SBPyPltImage vline. 'vline'}}} do: [:option |
		(bindings at: 'name') contents = option key ifTrue: [
			self addMorphBack: (self
				createBinding: [
					SBSelect new
						prefix: option key, '=';
						entryMorphs: option value]
				object: 'value').
			^ self]].
	^ nil
]
