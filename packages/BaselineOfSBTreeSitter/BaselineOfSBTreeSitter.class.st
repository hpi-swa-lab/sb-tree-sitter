Class {
	#name : #BaselineOfSBTreeSitter,
	#superclass : #BaselineOf,
	#category : #BaselineOfSBTreeSitter
}

{ #category : #baseline }
BaselineOfSBTreeSitter >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec preLoadDoIt: #preload:package:.
		" smalltalk needed for the tool integration "
		spec baseline: 'Sandblocks' with: [
			spec
				repository: 'github://tom95/sandblocks/packages';
				loads: #('Sandblocks-Core' 'Sandblocks-Smalltalk')].
		spec project: 'FFI' with: [
			spec
				className: 'ConfigurationOfFFI';
				repository: 'http://www.squeaksource.com/MetacelloRepository';
				versionString: #development;
				loads: #('Core')].
		spec project: 'OSProcess' with: [
			spec
				className: 'ConfigurationOfOSProcess';
				repository: 'http://www.squeaksource.com/MetacelloRepository';
				versionString: #stable;
				loads: #('Core')].
		spec package: 'JSON' with: [
			spec
				file: 'JSON-ul.35';
				repository: 'https://www.squeaksource.com/JSON'].
		
		spec
			package: 'Sandblocks-TreeSitter' with: [spec requires: #('Sandblocks' 'FFI' 'JSON' 'OSProcess')];
			package: 'Sandblocks-Javascript' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Python' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Regex' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Json' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-C' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Vhdl' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-TSSmalltalk' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Bash' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Matplotlib' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-RequestsTool' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Clojure' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Typescript' with: [spec requires: #('Sandblocks-TreeSitter')].
		
		spec
			group: 'default'
			with: #('Sandblocks-TreeSitter' 'Sandblocks-Javascript' 'Sandblocks-Python' 'Sandblocks-Regex' 'Sandblocks-Json' 'Sandblocks-C' 'Sandblocks-Vhdl' 'Sandblocks-Bash' 'Sandblocks-Clojure' 'Sandblocks-TSSmalltalk' 'Sandblocks-Typescript' 'Sandblocks-Matplotlib' 'Sandblocks-RequestsTool')]
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> depSqueakSource: aMCRepository name: aString targetRepository: anotherMCRepository [
	"taken from https://github.com/LinqLover/SimulationStudio/blob/master/packages/BaselineOfSimulationStudio.package/BaselineOfSimulationStudio.class/instance/depSqueakSource.name.targetRepository..st"

	(aMCRepository isKindOf: MCRepository) ifFalse: [
		^ self
			depSqueakSource: (MCRepository in: aMCRepository)
			name: aString
			targetRepository: anotherMCRepository].
	(anotherMCRepository isKindOf: MCRepository) ifFalse: [
		^ self
			depSqueakSource: aMCRepository
			name: aString
			targetRepository: (MCRepository in: anotherMCRepository)].
	
	^ ('{1} ({2})' format: {aString. aMCRepository description}) -> [ | packageName |
		packageName := aString, '.mcz'.
		[Installer new primMerge: packageName from: aMCRepository]
			on: MCPackageNotFound
			do: [:ex |
				(anotherMCRepository notNil
					and: [ex repository == aMCRepository]
					and: [ex packageName = packageName]) ifFalse: [ex pass].
				self notify: ('Preview version {1} has already been integrated' format: {aString})]
			on: MCMergeResolutionRequest
			do: [:ex |
				Smalltalk isHeadless ifFalse: [ex pass].
				self error: ex description]]
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> preload: loader package: packageSpec [

	(self depSqueakSource: #inbox name: 'Multilingual-ct.259' targetRepository: #trunk) value value.
	"(Installer url: 'https://tmbe.me/c/Regex-Core-ct.75.mcz') install"
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> projectClass [
	^ Smalltalk
		at: #MetacelloCypressBaselineProject
		ifAbsent: [super projectClass]
]
