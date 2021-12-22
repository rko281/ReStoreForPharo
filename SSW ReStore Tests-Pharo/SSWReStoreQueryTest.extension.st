Extension { #name : #SSWReStoreQueryTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreQueryTest class >> compiler [

	^ super compiler options: #(- optionInlineAndOr)
]
