Extension { #name : #SSWReStoreImplicitTrueQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreImplicitTrueQueryTest class >> compiler [

	^ super compiler options: #(- optionInlineAndOr)
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreImplicitTrueQueryTest class >> initialize [ 

	"Need to recompile with compiler options"
	self withAllSubclassesDo: [ :each | each recompile ]
]
