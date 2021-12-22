Extension { #name : #SSWReStoreImplicitTrueQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreImplicitTrueQueryTest class >> compiler [

	^ super compiler options: #(- optionInlineAndOr)
]
