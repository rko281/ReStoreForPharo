Extension { #name : #SSWReStoreQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreQueryTest class >> compiler [

	^ super compiler options: #(- optionInlineAndOr)
]

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreQueryTest class >> initialize [ 

	"Need to recompile with compiler options"
	self withAllSubclassesDo: [ :each | each recompile ]
]
