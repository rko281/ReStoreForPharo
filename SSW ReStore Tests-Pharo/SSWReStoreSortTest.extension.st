Extension { #name : #SSWReStoreSortTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreSortTest class >> compiler [

	^ super compiler options: #(- optionInlineAndOr)
]
