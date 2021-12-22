Extension { #name : #SimplePerson }

{ #category : #'*SSW ReStore Tests-Pharo' }
SimplePerson class >> compiler [

	^ super compiler options: #(- optionInlineAndOr optionInlineIfNil)
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SimplePerson class >> initialize [ 

	"Need to recompile with compiler options"
	super initialize.
	self withAllSubclassesDo: [ :each | each recompile ]
]
