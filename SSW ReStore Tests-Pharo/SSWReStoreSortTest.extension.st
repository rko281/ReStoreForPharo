Extension { #name : #SSWReStoreSortTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreSortTest class >> compiler [

	^ super compiler options: #(- optionInlineAndOr)
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreSortTest class >> initialize [ 

	"Need to recompile with compiler options"
	super initialize.
	self withAllSubclassesDo: [ :each | each recompile ]
]
